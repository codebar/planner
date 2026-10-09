require 'rails_helper'

RSpec.describe WaitingListsController do
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop:) }

  describe 'POST #create' do
    it 'creates a waiting list entry on first submission' do
      expect do
        post :create, params: { invitation_id: invitation.token }
      end.to change(WaitingList, :count).by(1)
    end

    it 'displays success message on first submission' do
      post :create, params: { invitation_id: invitation.token }

      expect(response).to redirect_to(invitation_path(invitation))
      expect(flash[:notice]).to eq('You have been added to the waiting list')
    end

    it 'does not create duplicate on second submission' do
      post :create, params: { invitation_id: invitation.token }

      expect do
        post :create, params: { invitation_id: invitation.token }
      end.not_to change(WaitingList, :count)
    end

    it 'maintains idempotency' do
      post :create, params: { invitation_id: invitation.token }
      post :create, params: { invitation_id: invitation.token }

      expect(WaitingList.where(invitation:).count).to eq(1)
    end

    context 'without a CSRF token (browser did not send session cookie)' do
      # Simulate the real-world scenario where the browser withholds the
      # session cookie (e.g. Safari/WebKit ITP on cross-site navigation).
      # The invitation token in the URL is the authenticator.
      include_context 'with forgery protection enforced'

      it 'still adds the member to the waiting list' do
        expect do
          post :create, params: { invitation_id: invitation.token }
        end.to change(WaitingList, :count).by(1)
      end
    end

    context 'when the custom close time has passed' do
      let(:workshop) { Fabricate(:workshop, rsvp_closes_at: 1.hour.ago, date_and_time: 4.hours.from_now) }

      it 'does not create a waiting list entry' do
        expect do
          post :create, params: { invitation_id: invitation.token }
        end.not_to change(WaitingList, :count)
      end

      it 'redirects with a closed message' do
        post :create, params: { invitation_id: invitation.token }

        expect(flash[:notice]).to include('RSVPs have now closed for this workshop')
      end
    end

    context 'when the 3.5 hour freeze has been reached' do
      let(:workshop) { Fabricate(:workshop, date_and_time: 3.hours.from_now) }

      it 'does not create a waiting list entry' do
        expect do
          post :create, params: { invitation_id: invitation.token }
        end.not_to change(WaitingList, :count)
      end
    end

    context 'when the custom close time is later than the freeze' do
      let(:workshop) { Fabricate(:workshop, rsvp_closes_at: 2.hours.from_now, date_and_time: 4.hours.from_now) }

      # The earlier of the two instants is the gate: joins still work until
      # the freeze, even though the custom close time has not passed yet.
      it 'creates a waiting list entry' do
        expect do
          post :create, params: { invitation_id: invitation.token }
        end.to change(WaitingList, :count).by(1)
      end
    end

    context 'when the freeze passed but the custom close time is still in the future' do
      let(:workshop) { Fabricate(:workshop, rsvp_closes_at: 2.hours.from_now, date_and_time: 3.hours.from_now) }

      it 'does not create a waiting list entry' do
        expect do
          post :create, params: { invitation_id: invitation.token }
        end.not_to change(WaitingList, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'without a CSRF token (browser did not send session cookie)' do
      include_context 'with forgery protection enforced'

      it 'still removes the member from the waiting list' do
        waiting_list = Fabricate(:waiting_list)
        invitation = waiting_list.invitation

        expect do
          delete :destroy, params: { invitation_id: invitation.token }
        end.to change(WaitingList, :count).by(-1)
      end
    end

    context 'when the waitlist is closed' do
      let(:waiting_list) { Fabricate(:waiting_list) }
      let(:invitation) { waiting_list.invitation }

      before do
        invitation.workshop.update!(date_and_time: 3.hours.from_now)
        invitation # materialize the fabricated waiting list entry outside the change block
      end

      it 'keeps the entry on the waiting list' do
        expect do
          delete :destroy, params: { invitation_id: invitation.token }
        end.not_to change(WaitingList, :count)
      end

      it 'redirects with a closed message' do
        delete :destroy, params: { invitation_id: invitation.token }

        expect(flash[:notice]).to include('RSVPs have now closed for this workshop')
      end
    end

    context 'when the waitlist is open' do
      let(:waiting_list) { Fabricate(:waiting_list) }
      let(:invitation) { waiting_list.invitation }

      before { invitation } # materialize the fabricated waiting list entry outside the change block

      it 'removes the entry' do
        expect do
          delete :destroy, params: { invitation_id: invitation.token }
        end.to change(WaitingList, :count).by(-1)
      end
    end
  end
end
