require 'rails_helper'

RSpec.describe WorkshopsController do
  let(:member) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop) }

  describe 'GET #show' do
    context 'when a visitor (not logged in)' do
      render_views

      it 'responds with conditional GET headers' do
        get :show, params: { id: workshop.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers['etag']).to be_present
        expect(response.headers['last-modified']).to be_present
      end

      it 'returns 304 for a conditional repeat request' do
        get :show, params: { id: workshop.id }
        etag = response.headers['etag']

        request.headers['HTTP_IF_NONE_MATCH'] = etag
        get :show, params: { id: workshop.id }

        expect(response).to have_http_status(:not_modified)
      end

      it 'renders the page again when the workshop has changed' do
        get :show, params: { id: workshop.id }
        etag = response.headers['etag']

        workshop.update!(description: '<p>Updated description</p>')

        request.headers['HTTP_IF_NONE_MATCH'] = etag
        get :show, params: { id: workshop.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Updated description')
      end
    end

    context 'when logged in' do
      before { login(member) }

      it 'renders without conditional GET headers' do
        get :show, params: { id: workshop.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers['Last-Modified']).to be_nil
      end
    end
  end

  describe 'POST #rsvp' do
    before { login(member) }

    context 'when the member already has an invitation for the workshop and role with attending nil' do
      let!(:invitation) do
        Fabricate(:workshop_invitation, workshop:, member:, role: 'Coach', attending: nil)
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

    context 'when the member has an invitation with a different role' do
      let!(:invitation) do
        Fabricate(:workshop_invitation, workshop:, member:, role: 'Student', attending: nil)
      end

      it 'updates the existing invitation to the requested role instead of creating a second one' do
        expect do
          post :rsvp, params: { id: workshop.id, role: 'Coach' }
        end.not_to change(WorkshopInvitation, :count)

        expect(invitation.reload.role).to eq('Coach')
        expect(response).to redirect_to(invitation_path(invitation))
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
        Fabricate(:attending_workshop_invitation, workshop:, member:, role: 'Coach')
      end

      it 'redirects back with already wish to attend message' do
        post :rsvp, params: { id: workshop.id, role: 'Coach' }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('workshops.already_wish_to_attend'))
      end
    end
  end
end
