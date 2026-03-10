RSpec.describe InvitationsController do
  let(:event) { Fabricate(:event) }

  describe 'GET #show' do
    context 'with invalid token' do
      it 'returns http not found' do
        get :show, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #attend' do
    context 'with invalid token' do
      it 'returns http not found' do
        post :attend, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #reject' do
    context 'with invalid token' do
      it 'returns http not found' do
        post :reject, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
