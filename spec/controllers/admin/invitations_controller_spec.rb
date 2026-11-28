require 'rails_helper'

RSpec.describe Admin::InvitationsController do
  let(:invitation) { Fabricate(:student_workshop_invitation) }
  let(:workshop) { invitation.workshop }
  let(:admin) { Fabricate(:chapter_organiser) }

  describe 'PUT #update' do
    before do
      admin.add_role(:organiser, workshop.chapter)

      login admin
      request.env['HTTP_REFERER'] = '/admin/member/3'
    end

    it 'Successfuly updates an invitation' do
      expect(invitation.attending).to be_nil

      put :update, params: { id: invitation.token, workshop_id: workshop.id, attending: 'true' }

      expect(invitation.reload.attending).to be true
      expect(flash[:notice]).to match('You have added')
    end

    # While similar to the previous test, this specifically tests that organisers
    # have the ability to manually add a student to the workshop that has not
    # selected a tutorial. This is helpful for when a student shows up for a
    # workshop they have not have a spot — this happens from time to time.
    it 'Successfuly adds a user as attenting, even without a tutorial' do
      invitation.update_attribute(:tutorial, nil)
      expect(invitation.automated_rsvp).to be_nil

      put :update, params: { id: invitation.token, workshop_id: workshop.id, attending: 'true' }
      invitation.reload

      expect(invitation.attending).to be true
      expect(invitation.automated_rsvp).to be true
      expect(flash[:notice]).to match('You have added')
    end

    it 'Records the organiser ID that overrides an invitations' do
      put :update, params: { id: invitation.token, workshop_id: workshop.id, attending: 'true' }
      invitation.reload

      expect(invitation.last_overridden_by_id).to be admin.id
    end
  end

  describe 'PUT #update with attended param' do
    let(:workshop) { Fabricate(:workshop, date_and_time: Time.zone.now - 1.day) }
    let(:invitation) { Fabricate(:workshop_invitation, workshop:, attending: true) }
    let(:admin) { Fabricate(:chapter_organiser) }

    before do
      admin.add_role(:organiser, workshop.chapter)
      login admin
      request.env['HTTP_REFERER'] = "/admin/workshop/#{workshop.id}"
    end

    it 'renders the attendance row partial via XHR when verifying' do
      put :update, params: { id: invitation.token, workshop_id: workshop.id, attended: true }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/html')
      expect(invitation.reload.attended).to be true
    end

    it 'renders the attendance row partial via XHR when unverifying' do
      invitation.update!(attended: true)

      put :update, params: { id: invitation.token, workshop_id: workshop.id, attended: false }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/html')
      expect(invitation.reload.attended).to be_nil
    end
  end

  describe 'PUT #update (RSVP page toggle)' do
    before do
      admin.add_role(:organiser, workshop.chapter)
      login admin
    end

    it 'toggles attending on and redirects back to the rsvp page' do
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'true' }

      expect(invitation.reload.attending).to be(true)
      expect(response).to redirect_to(admin_workshop_rsvp_url(workshop))
    end

    it 'toggles an attending invitation back to not attending' do
      invitation.update!(attending: true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(invitation.reload.attending).to be(false)
      expect(response).to redirect_to(admin_workshop_rsvp_url(workshop))
    end

    it 'promotes the next waitlisted member when the workshop is in the future' do
      invitation.update!(attending: true)
      waitlisted_invitation = Fabricate(:workshop_invitation, workshop:, tutorial: nil)
      WaitingList.add(waitlisted_invitation, true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(waitlisted_invitation.reload.attending).to be(true)
    end

    it 'does not promote when the removed invitation never held a seat' do
      invitation.update!(attending: nil)
      waitlisted_invitation = Fabricate(:workshop_invitation, workshop:, tutorial: nil)
      WaitingList.add(waitlisted_invitation, true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(waitlisted_invitation.reload.attending).to be_nil
    end

    it 'does not promote when the removed invitation already declined' do
      invitation.update!(attending: false)
      waitlisted_invitation = Fabricate(:workshop_invitation, workshop:, tutorial: nil)
      WaitingList.add(waitlisted_invitation, true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(waitlisted_invitation.reload.attending).to be_nil
    end

    it 'does not promote from the waiting list when the workshop has started' do
      workshop.update!(date_and_time: 1.hour.ago, ends_at: 1.hour.ago + 2.hours)
      invitation.update!(attending: true)
      waitlisted_invitation = Fabricate(:workshop_invitation, workshop:, tutorial: nil)
      WaitingList.add(waitlisted_invitation, true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(waitlisted_invitation.reload.attending).to be_nil
    end

    it 'redirects back preserving the search term and page' do
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop, q: 'Zoe', page: 2)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'true' }

      expect(invitation.reload.attending).to be(true)
      expect(response).to redirect_to(admin_workshop_rsvp_path(workshop, q: 'Zoe', page: 2))
    end
  end

  context 'when recording activity' do
    before do
      admin.add_role(:organiser, workshop.chapter)
      login admin
      request.env['HTTP_REFERER'] = '/admin/member/3'
    end

    it 'records invitation.rsvp_override when admin forces attending' do
      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'true' }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.rsvp_override',
                                              recipient: invitation.member)).to be(true)
    end
  end

  describe 'PUT #update (attendee pairing note)' do
    let(:student_invitation) do
      Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: true, attended: true,
                                      checked_in_at: 5.minutes.ago, tutorial: 'Python', note: 'Loops')
    end
    let(:coach_invitation) do
      Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: true, attended: true,
                                      checked_in_at: 4.minutes.ago, tutorial: nil, note: 'Ruby & Rails')
    end

    before do
      admin.add_role(:organiser, workshop.chapter)
      login admin
    end

    it 'updates a student note via XHR without sending emails or altering tutorial or check-in state' do
      original_checked_in_at = student_invitation.checked_in_at
      expect do
        put :update,
            params: { workshop_id: workshop.id, id: student_invitation.token,
                      workshop_invitation: { tutorial: 'Should be ignored', note: 'Switched to JavaScript today' } },
            xhr: true
      end.not_to(change { ActionMailer::Base.deliveries.count })

      expect(response).to have_http_status(:success)
      student_invitation.reload
      expect(student_invitation.tutorial).to eq('Python')
      expect(student_invitation.note).to eq('Switched to JavaScript today')
      expect(student_invitation.attended).to be(true)
      expect(student_invitation.checked_in_at.to_i).to eq(original_checked_in_at.to_i)
      expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.note_updated',
                                              recipient: student_invitation.member)).to be(true)
    end

    it 'updates a coach note via XHR and records who updated it' do
      put :update,
          params: { workshop_id: workshop.id, id: coach_invitation.token,
                    workshop_invitation: { note: 'JavaScript & React' } },
          xhr: true

      expect(response).to have_http_status(:success)
      coach_invitation.reload
      expect(coach_invitation.note).to eq('JavaScript & React')
      expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.note_updated',
                                              recipient: coach_invitation.member)).to be(true)
    end

    it 'clears a note when submitted blank' do
      put :update,
          params: { workshop_id: workshop.id, id: student_invitation.token,
                    workshop_invitation: { note: '   ' } },
          xhr: true

      expect(response).to have_http_status(:success)
      expect(student_invitation.reload.note).to be_nil
    end
  end
end
