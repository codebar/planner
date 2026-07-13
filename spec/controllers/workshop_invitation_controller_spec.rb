RSpec.describe WorkshopInvitationController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:tutorial) { Fabricate(:tutorial) }
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member, tutorial: tutorial.title) }

  before { login(member) }

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: invitation.token }
      expect(response).to be_successful
    end
  end

  describe 'POST #accept' do
    context 'when invitation can be accepted' do
      it 'sets attending to true' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.attending).to be true
      end

      it 'sets rsvp_time' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.rsvp_time).to be_present
      end

      it 'redirects back with success message' do
        post :accept, params: { id: invitation.token }
        expect(response).to redirect_to(invitation_path(invitation))
        expect(flash[:notice]).to include('Thanks for getting back to us')
      end
    end

    context 'when already attending' do
      before { invitation.update!(attending: true) }

      it 'does not change attendance' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.attending).to be true
      end

      it 'redirects with already RSVPed message' do
        post :accept, params: { id: invitation.token }
        expect(flash[:notice]).to include('already confirmed your attendance')
      end
    end

    context 'when RSVPs are closed' do
      before { workshop.update!(rsvp_closes_at: 1.hour.ago) }

      it 'does not change attendance' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.attending).to be_nil
      end

      it 'redirects with closed message' do
        post :accept, params: { id: invitation.token }
        expect(flash[:notice]).to include('closed')
      end
    end

    context 'when workshop is full' do
      before do
        capacity = workshop.host.seats
        capacity.times do
          m = Fabricate(:member)
          Fabricate(:workshop_invitation, workshop: workshop, member: m, role: 'Student', attending: true)
        end
      end

      it 'does not change attendance' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.attending).to be_nil
      end

      it 'redirects with no seats message' do
        post :accept, params: { id: invitation.token }
        expect(flash[:notice]).to include('no more spots left')
      end
    end

    context 'when tutorial is missing for student' do
      let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member, tutorial: nil) }

      it 'does not change attendance' do
        post :accept, params: { id: invitation.token }
        expect(invitation.reload.attending).to be_nil
      end

      it 'redirects with validation error' do
        post :accept, params: { id: invitation.token }
        expect(flash[:notice].join).to include('Tutorial')
      end
    end
  end

  describe 'POST #reject' do
    context 'when invitation can be rejected' do
      it 'sets attending to false' do
        post :reject, params: { id: invitation.token }
        expect(invitation.reload.attending).to be false
      end

      it 'redirects with rejection message' do
        post :reject, params: { id: invitation.token }
        expect(flash[:notice]).to include('so sad you')
      end
    end

    context 'when already rejected' do
      before { invitation.update!(attending: false) }

      it 'does not change attendance' do
        post :reject, params: { id: invitation.token }
        expect(invitation.reload.attending).to be false
      end

      it 'redirects with already not attending message' do
        post :reject, params: { id: invitation.token }
        expect(flash[:notice]).to include("already confirmed you can't make it")
      end
    end

    context 'when past deadline' do
      before do
        workshop.update!(
          rsvp_closes_at: 1.hour.ago,
          date_and_time: 4.hours.from_now
        )
      end

      it 'does not change attendance' do
        post :reject, params: { id: invitation.token }
        expect(invitation.reload.attending).to be_nil
      end

      it 'redirects with deadline message' do
        post :reject, params: { id: invitation.token }
        expect(flash[:notice]).to include('3.5 hours')
      end
    end

    context 'when someone is on waiting list' do
      let(:waitlisted_member) { Fabricate(:member) }
      let(:waitlisted_invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: waitlisted_member, role: 'Student') }

      before do
        invitation.update!(attending: true)
        WaitingList.add(waitlisted_invitation, auto_rsvp: true)
      end

      it 'promotes waiting list member' do
        post :reject, params: { id: invitation.token }
        expect(waitlisted_invitation.reload.attending).to be true
      end
    end
  end

  describe 'PATCH #update' do
    before { invitation.update!(attending: true) }

    context 'with valid params' do
      it 'updates the tutorial' do
        new_tutorial = Fabricate(:tutorial)
        patch :update, params: { id: invitation.token, workshop_invitation: { tutorial: new_tutorial.title } }
        expect(invitation.reload.tutorial).to eq(new_tutorial.title)
      end

      it 'redirects with success message' do
        patch :update, params: { id: invitation.token, workshop_invitation: { tutorial: tutorial.title } }
        expect(flash[:notice]).to include('updated')
      end
    end

    context 'with invalid params' do
      it 'does not update the invitation' do
        patch :update, params: { id: invitation.token, workshop_invitation: { tutorial: '' } }
        expect(invitation.reload.tutorial).to eq(tutorial.title)
      end

      it 'redirects with error message' do
        patch :update, params: { id: invitation.token, workshop_invitation: { tutorial: '' } }
        expect(flash[:notice].join).to include('Tutorial')
      end
    end
  end
end
