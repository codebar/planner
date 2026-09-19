# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin member management activity' do
  let(:admin) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }
  let(:member) { Fabricate(:member) }
  let(:group) { Fabricate(:group) }

  before do
    admin.add_role(:admin)
    Fabricate(:auth_service, member: admin, provider: 'github', uid: 'admin-uid-1')
    mock_auth_hash(provider: 'github', uid: 'admin-uid-1', email: admin.email)
    post '/auth/github/callback'
  end

  describe 'subscription changes' do
    it 'records subscription.admin_updated when admin removes a subscription' do
      member.subscriptions.create!(group:)

      get admin_member_update_subscriptions_path(member), params: { group: group.id }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'subscription.admin_updated',
                                              recipient: member)).to be(true)
    end
  end

  describe 'meeting invitations' do
    it 'records meeting_invitation.created on admin invite' do
      meeting = Fabricate(:meeting)

      post admin_meeting_invitations_path,
           params: { meeting_invitations: { member: member.id, meeting_id: meeting.slug } }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'meeting_invitation.created',
                                              recipient: member)).to be(true)
    end

    it 'records meeting_invitation.updated on admin update' do
      meeting = Fabricate(:meeting)
      invitation = Fabricate(:meeting_invitation, member:, meeting:)

      patch admin_meeting_invitation_path(invitation),
            params: { attendance_status: 'true' }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'meeting_invitation.updated',
                                              recipient: member)).to be(true)
    end
  end
end
