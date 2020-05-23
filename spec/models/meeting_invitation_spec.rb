require 'spec_helper'

RSpec.describe MeetingInvitation, type: :model  do
  it_behaves_like InvitationConcerns, :meeting_invitation

  context 'validates' do
    it { is_expected.to validate_presence_of(:meeting) }
    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_uniqueness_of(:member_id).scoped_to(:meeting_id) }
  end
end
