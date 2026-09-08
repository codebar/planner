# spec/requests/member_logout_activity_spec.rb
require 'rails_helper'

RSpec.describe 'Member logout activity' do
  it 'records member.logout before clearing the session' do
    member = Fabricate(:member, email: 'logout@example.com')
    Fabricate(:auth_service, member:, provider: 'github', uid: 'logout-uid-1')
    mock_auth_hash(provider: 'github', uid: 'logout-uid-1', email: member.email)
    post '/auth/github/callback'

    expect { delete '/logout' }
      .to change { PublicActivity::Activity.exists?(owner: member, key: 'member.logout') }
      .from(false).to(true)
  end
end
