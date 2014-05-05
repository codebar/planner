namespace :reminders do
  desc "Send out reminders"

  task workshop: :environment do
    workshop = Sessions.next

    if workshop.date_and_time - 24.hours > DateTime.now and workshop.date_and_time - 40.hours < DateTime.now
      InvitationManager.send_workshop_attendance_reminders(workshop)
    end
  end
end
