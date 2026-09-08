# spec/requests/member_activity_profile_spec.rb
require 'rails_helper'

RSpec.describe 'Profile activity' do
  let(:member) { Fabricate(:member, email: 'profile@example.com') }

  before do
    Fabricate(:auth_service, member:, provider: 'github', uid: 'profile-uid-1')
    mock_auth_hash(provider: 'github', uid: 'profile-uid-1', email: member.email)
    post '/auth/github/callback' # sign in via real OAuth callback
  end

  it 'records profile.updated on MembersController#update' do
    put member_path(member), params: { member: { about_you: 'updated bio' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'profile.updated')).to be(true)
  end

  it 'records profile.updated on Member::DetailsController#update' do
    put member_details_path, params: { member: { about_you: 'details bio', how_you_found_us: 'social_media' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'profile.updated')).to be(true)
  end

  it 'records toc.accepted' do
    # Seed session[:previous_request_url] via a GET to root_path —
    # accept_terms before_action fires, calls store_path, then redirects
    # to terms_and_conditions (which skips accept_terms)
    get root_path

    put terms_and_conditions_path, params: { terms_and_conditions_form: { terms: '1' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'toc.accepted')).to be(true)
  end
end
