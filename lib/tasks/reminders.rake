namespace :reminders do
  desc "Send out reminders"

  task sessions: :environment do
    Sessions.upcoming.first.tap do |session|
      unless Reminders.session(session).exists?
        invitations = InvitationManager.send_session_reminders(session)

        Reminders.add_for_session session, invitations.length
      end
    end
  end
end
