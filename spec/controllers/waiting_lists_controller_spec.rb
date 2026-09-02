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
  end
end
