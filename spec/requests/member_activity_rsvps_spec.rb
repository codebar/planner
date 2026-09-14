require 'rails_helper'

RSpec.describe 'Event and meeting RSVP activity' do
  let(:member) { Fabricate(:member) }

  before do
    ApplicationController.prepend(LoginHelpers::LoginStub) unless ApplicationController < LoginHelpers::LoginStub
    LoginHelpers::LoginStub.current_user = member
  end

  after { LoginHelpers::LoginStub.current_user = nil }

  describe 'event RSVPs' do
    let(:invitation) { Fabricate(:invitation, member:) }

    it 'records event_invitation.rsvp on attend' do
      post event_attend_path(invitation.event.id, invitation.token)

      expect(PublicActivity::Activity.exists?(owner: member, key: 'event_invitation.rsvp')).to be(true)
    end

    it 'records event_invitation.rejected on reject' do
      invitation.update!(attending: true)
      post event_reject_path(invitation.event.id, invitation.token)

      expect(PublicActivity::Activity.exists?(owner: member, key: 'event_invitation.rejected')).to be(true)
    end
  end

  describe 'meeting RSVPs' do
    let(:invitation) { Fabricate(:meeting_invitation, member:) }

    it 'records meeting_invitation.rsvp' do
      get meeting_invitation_path(invitation.meeting), params: { token: invitation.token }

      expect(PublicActivity::Activity.exists?(owner: member, key: 'meeting_invitation.rsvp')).to be(true)
    end

    it 'records meeting_invitation.cancelled' do
      invitation.update!(attending: true)
      get meeting_cancel_path(invitation.meeting, invitation.token)

      expect(PublicActivity::Activity.exists?(owner: member, key: 'meeting_invitation.cancelled')).to be(true)
    end
  end
end
