class CleanupExpiredInvitationLogsJob < ApplicationJob
  queue_as :default

  def perform
    InvitationLog.destroy_by(expires_at: ..Time.current)
  end
end
