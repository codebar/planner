class InvitationLogEntry < ApplicationRecord
  enum :status, { success: 'success', failed: 'failed', skipped: 'skipped' }, prefix: false

  belongs_to :invitation_log
  belongs_to :member
  belongs_to :invitation, polymorphic: true, optional: true
end
