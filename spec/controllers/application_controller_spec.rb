RSpec.describe ApplicationController do
  describe '#render_not_found' do
    controller do
      def index
        raise ActiveRecord::RecordNotFound
      end
    end

    context 'with HTML format' do
      before do
        get :index, format: :html
      end

      it 'renders the not_found template' do
        expect(response.status).to eq(404)
        expect(response).not_to be_redirect
      end
    end

    context 'with JSON format' do
      before do
        get :index, format: :json
      end

      it 'returns empty 404 response' do
        expect(response.status).to eq(404)
        expect(response.body).to be_empty
      end
    end
  end

  describe '#render_not_acceptable' do
    controller do
      def index
        raise ActionController::UnknownFormat
      end
    end

    context 'with HTML format' do
      before do
        get :index, format: :html
      end

      it 'renders the not_acceptable template' do
        expect(response.status).to eq(406)
        expect(response).not_to be_redirect
      end
    end

    context 'with JSON format' do
      before do
        get :index, format: :json
      end

      it 'returns empty 406 response' do
        expect(response.status).to eq(406)
        expect(response.body).to be_empty
      end
    end

    context 'with XML format' do
      before do
        get :index, format: :xml
      end

      it 'returns empty 406 response' do
        expect(response.status).to eq(406)
        expect(response.body).to be_empty
      end
    end
  end
end
