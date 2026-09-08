# spec/requests/member_activity_subscriptions_spec.rb
require 'rails_helper'

RSpec.describe 'Subscription and mailing list activity' do
  let(:member) { Fabricate(:member) }
  let(:group) { Fabricate(:group) }

  before do
    Fabricate(:auth_service, member:, provider: 'github', uid: 'subs-uid-1')
    mock_auth_hash(provider: 'github', uid: 'subs-uid-1', email: member.email)
    post '/auth/github/callback' # sign in via real OAuth callback
  end

  it 'records subscription.created and subscription.removed' do
    post subscriptions_path, params: { subscription: { group_id: group.id } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'subscription.created')).to be(true)

    delete destroy_subscriptions_path, params: { subscription: { group_id: group.id } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'subscription.removed')).to be(true)
  end

  it 'records mailing_list.subscribe and unsubscribe' do
    post mailing_lists_path
    expect(PublicActivity::Activity.exists?(owner: member, key: 'mailing_list.subscribe')).to be(true)

    delete mailing_lists_path
    expect(PublicActivity::Activity.exists?(owner: member, key: 'mailing_list.unsubscribe')).to be(true)
  end
end
