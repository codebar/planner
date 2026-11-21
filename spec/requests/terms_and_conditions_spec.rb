require 'rails_helper'

RSpec.describe 'Terms and conditions acceptance' do
  let(:member) { Fabricate(:member_without_toc) }

  before do
    Fabricate(:auth_service, member:, provider: 'github', uid: 'toc-uid-1')
    mock_auth_hash(provider: 'github', uid: 'toc-uid-1', email: member.email)
    post '/auth/github/callback'
  end

  it 'does not record acceptance when terms is null' do
    patch terms_and_conditions_path,
          params: { terms_and_conditions_form: { terms: nil } }.to_json,
          headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(member.reload.accepted_toc_at).to be_nil
    expect(response).to have_http_status(:ok)
  end
end
