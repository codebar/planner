RSpec.describe Admin::AnnouncementsController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:announcement) { Fabricate(:announcement) }

  before do
    login_as_admin(member)
  end

  describe 'GET #new' do
    render_views

    it 'renders with a native date input' do
      get :new

      expect(response.body).to include('type="date"')
    end
  end

  describe 'GET #edit' do
    render_views

    it 'pre-fills the date value in ISO format' do
      get :edit, params: { id: announcement.id }

      expect(response.body).to include("value=\"#{announcement.expires_at.strftime('%Y-%m-%d')}\"")
    end
  end
end
