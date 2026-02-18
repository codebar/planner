RSpec.describe WaitingListsController do
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop) }

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

      expect(WaitingList.where(invitation: invitation).count).to eq(1)
    end
  end
end
