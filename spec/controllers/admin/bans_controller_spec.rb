RSpec.describe Admin::BansController do
  let(:member) { Fabricate(:member) }
  let(:admin) { Fabricate(:member) }

  before do
    login_as_admin(admin)
  end

  describe 'GET #new' do
    render_views

    it 'renders with a native date input' do
      get :new, params: { member_id: member.id }

      expect(response.body).to include('type="date"')
    end

    it 'defaults to approximately one month from today' do
      get :new, params: { member_id: member.id }

      expected = (Time.zone.now + 1.month).strftime('%Y-%m-%d')
      expect(response.body).to include("value=\"#{expected}\"")
    end
  end
end
