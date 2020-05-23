require 'spec_helper'

RSpec.describe MeetingInvitation, type: :model  do
  it_behaves_like InvitationConcerns, :meeting_invitation
end
