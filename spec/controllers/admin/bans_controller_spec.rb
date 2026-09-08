# frozen_string_literal: true

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

  describe 'POST #create' do
    it 'records member.banned' do
      expect do
        post :create, params: { member_id: member.id, ban: { reason: 'spam', note: 'banned member',
                                                             explanation: 'test', permanent: '1',
                                                             expires_at: 1.month.from_now.to_s } }
      end.to change {
               PublicActivity::Activity.exists?(owner: admin, key: 'member.banned',
                                                recipient: member)
             }.from(false).to(true)
    end
  end
end
