RSpec.describe EventsController do
  describe '#fetch_upcoming_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_upcoming_events)).to eq([{}, nil])
      end
    end
  end

  describe '#fetch_past_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_past_events)).to eq([{}, nil])
      end
    end
  end

  describe '#past' do
    before { Fabricate(:event, date_and_time: 2.weeks.ago) }

    context 'when the page param is invalid' do
      it 'clamps page 0 to page 1' do
        get :past, params: { page: 0 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles SQL injection probes' do
        get :past, params: { page: "' OR '1'='1" }
        expect(response).to have_http_status(:ok)
      end

      it 'handles empty page params' do
        get :past, params: { page: '' }
        expect(response).to have_http_status(:ok)
      end

      it 'handles negative pages' do
        get :past, params: { page: -3 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles array params' do
        get :past, params: { page: ['1'] }
        expect(response).to have_http_status(:ok)
      end
    end

    it 'renders the requested page' do
      get :past, params: { page: 1 }
      expect(response).to have_http_status(:ok)
    end
  end
end
