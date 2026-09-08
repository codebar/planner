# spec/requests/member_login_activity_spec.rb
require 'rails_helper'

RSpec.describe 'Member login activity' do
  it 'records member.login on the existing auth service path' do
    member = Fabricate(:member, email: 'existing-login@example.com')
    Fabricate(:auth_service, member:, provider: 'github', uid: 'login-uid-1')

    mock_auth_hash(provider: 'github', uid: 'login-uid-1', email: member.email)
    post '/auth/github/callback'

    expect(PublicActivity::Activity.exists?(owner: member, key: 'member.login')).to be(true)
  end

  it 'records member.login when the callback creates a new member' do
    mock_auth_hash(provider: 'github', uid: 'brand-new-uid', email: 'fresh-login@example.com')

    expect { post '/auth/github/callback' }
      .to change { PublicActivity::Activity.where(key: 'member.login').count }.by(1)
  end
end
