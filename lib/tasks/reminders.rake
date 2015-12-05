namespace :reminders do
  desc "Send out reminders"

  task workshop: :environment do
    workshops = Sessions.upcoming

    workshops.each do |workshop|
      if Time.zone.now.between?(workshop.date_and_time-30.hours, workshop.date_and_time - 4.hours)
        STDOUT.puts "Sending attendance reminders for workshop #{workshop.id}..."
        InvitationManager.send_workshop_attendance_reminders workshop
        STDOUT.puts "Sending waiting list reminders for workshop #{workshop.id}..."
        InvitationManager.send_workshop_waiting_list_reminders workshop
      end
    end
  end
end
