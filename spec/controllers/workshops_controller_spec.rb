RSpec.describe WorkshopsController do
  let(:member) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop) }

  before { login(member) }

  describe 'POST #rsvp' do
    context 'when the member already has an invitation for the workshop and role with attending nil' do
      let!(:invitation) do
        Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Coach', attending: nil)
      end

      it 'redirects to the existing invitation page' do
        post :rsvp, params: { id: workshop.id, role: 'Coach' }

        expect(response).to redirect_to(invitation_path(invitation))
      end

      it 'does not create a new invitation' do
        expect do
          post :rsvp, params: { id: workshop.id, role: 'Coach' }
        end.not_to change(WorkshopInvitation, :count)
      end
    end

    context 'when the member does not have an invitation for the workshop and role' do
      it 'creates a new invitation and redirects' do
        expect do
          post :rsvp, params: { id: workshop.id, role: 'Coach' }
        end.to change(WorkshopInvitation, :count).by(1)

        invitation = WorkshopInvitation.last
        expect(response).to redirect_to(invitation_path(invitation))
      end
    end

    context 'when the member is already attending' do
      before do
        Fabricate(:attending_workshop_invitation, workshop: workshop, member: member, role: 'Coach')
      end

      it 'redirects back with already wish to attend message' do
        post :rsvp, params: { id: workshop.id, role: 'Coach' }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('workshops.already_wish_to_attend'))
      end
    end
  end
end
