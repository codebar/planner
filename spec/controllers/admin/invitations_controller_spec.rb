RSpec.describe Admin::InvitationsController, type: :controller do
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
    let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }
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

    it 'redirects back preserving the search term and page' do
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop, q: 'Zoe', page: 2)

      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'true' }

      expect(invitation.reload.attending).to be(true)
      expect(response).to redirect_to(admin_workshop_rsvp_path(workshop, q: 'Zoe', page: 2))
    end
  end
end
