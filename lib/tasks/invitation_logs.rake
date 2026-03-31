namespace :invitation_logs do
  desc 'Clean up expired invitation logs'
  task cleanup: :environment do
    CleanupExpiredInvitationLogsJob.perform_now
  end
end
