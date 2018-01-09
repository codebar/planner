namespace :workshop do
  desc 'Send waiting list emails'

  task reminders: :environment do
    workshops = Workshop.upcoming

    workshops.each do |workshop|
      waiting_list = WaitingList.by_workshop(workshop)
      if waiting_list.exists?
        InvitationManager.send_waiting_list_emails(workshop)
      end
    end
  end
end
