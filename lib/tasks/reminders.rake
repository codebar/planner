namespace :reminders do
  desc "Send out reminders"

  task workshop: :environment do
    workshops = Sessions.upcoming

    workshops.each do |workshop|
      if DateTime.now.between?(workshop.date_and_time-30.hours, workshop.date_and_time - 4.hours)
        puts "Sending reminders for workshop #{workshop.id}..." unless Rails.env == 'test'
        InvitationManager.send_workshop_attendance_reminders(workshop)
      end
    end
  end
end
