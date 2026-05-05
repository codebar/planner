require 'rails_helper'

RSpec.describe CleanupExpiredInvitationLogsJob do
  describe '#perform' do
    it 'destroys invitation logs that have expired' do
      expired_log = Fabricate(:invitation_log, expires_at: 1.day.ago)
      valid_log = Fabricate(:invitation_log, expires_at: 1.day.from_now)

      described_class.new.perform

      expect(InvitationLog.exists?(expired_log.id)).to be false
      expect(InvitationLog.exists?(valid_log.id)).to be true
    end

    it 'destroys associated entries via dependent: :destroy' do
      log = Fabricate(:invitation_log, expires_at: 1.day.ago)
      entry = Fabricate(:invitation_log_entry, invitation_log: log)

      described_class.new.perform

      expect(InvitationLogEntry.exists?(entry.id)).to be false
    end
  end
end
