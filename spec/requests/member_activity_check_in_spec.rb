# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Check-in activity' do
  let(:invitation) { Fabricate(:workshop_invitation) }
  let(:member) { invitation.member }
  let(:workshop) { invitation.workshop }
  let(:code) { 'my-check-code' }

  before do
    Fabricate(:auth_service, member:, provider: 'github', uid: 'checkin-uid-1')
    mock_auth_hash(provider: 'github', uid: 'checkin-uid-1', email: member.email)
    post '/auth/github/callback'
    workshop.update!(date_and_time: 1.hour.ago, check_in_code: code)
  end

  it 'records member.checked_in on valid self-check-in' do
    post check_in_w_path(code:), params: { role: 'Student' }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'member.checked_in')).to be(true)
  end

  it 'does not record for an invalid role' do
    post check_in_w_path(code:), params: { role: 'Invalid' }

    expect(PublicActivity::Activity.exists?(key: 'member.checked_in')).to be(false)
  end
end
