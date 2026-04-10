class InvitationLog < ApplicationRecord
  enum :action, { invite: 'invite', reminder: 'reminder', waiting_list_notification: 'waiting_list_notification' },
       prefix: false
  enum :status, { running: 'running', completed: 'completed', failed: 'failed' }, prefix: false

  belongs_to :loggable, polymorphic: true
  belongs_to :initiator, class_name: 'Member', optional: true
  belongs_to :chapter, optional: true
  has_many :entries, class_name: 'InvitationLogEntry', dependent: :destroy, autosave: false

  before_create :set_expires_at

  private

  def set_expires_at
    self.expires_at ||= 180.days.from_now
  end
end
