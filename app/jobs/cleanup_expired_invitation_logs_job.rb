class CleanupExpiredInvitationLogsJob < ApplicationJob
  queue_as :default

  def perform
    InvitationLog.where('expires_at < ?', Time.current).destroy_all
  end
end
