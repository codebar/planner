class InvitationLogEntry < ApplicationRecord
  enum :status, { success: 'success', failed: 'failed', skipped: 'skipped' }, prefix: false

  belongs_to :invitation_log
  belongs_to :member
  belongs_to :invitation, polymorphic: true, optional: true

  validates :member_id, uniqueness: { scope: %i[invitation_type invitation_id] }, allow_nil: true
end
