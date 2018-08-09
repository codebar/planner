namespace :workshop do
  desc 'Send waiting list emails'

  task reminders: :environment do
    workshops = Workshop.upcoming

    workshops.each do |workshop|
      waiting_list = WaitingList.by_workshop(workshop)
      InvitationManager.new.send_waiting_list_emails(workshop) if waiting_list.exists?
    end
  end
end
