def usage_example
  "Usage: rake member:delete'[email@address.com]'"
end

namespace :member do
  desc 'Delete member account'
  task :delete, [:email] => :environment do |_, args|
    email = args[:email]

    abort("You have to provide an email address. #{usage_example}") if email.blank?

    member = Member.find_by!(email: email)

    $stdout.puts "Deleting #{member.name} #{member.surname}'s account..."
    $stdout.puts 'This action is irreversible.'
    $stdout.puts 'Press any key to continue.'
    $stdin.getch

    ActiveRecord::Base.transaction do
      MailingList.new(ENV['NEWSLETTER_ID']).unsubscribe(member.email)

      member.auth_services.delete_all
      member.subscriptions.delete_all

      # generate new invitation tokens so the current email links stop working
      member.workshop_invitations.each do |invitation|
        invitation.send(:set_token)
        invitation.save
      end

      member.email = "deleted_user_#{Time.zone.now.to_s(:number)}@codebar.io"
      member.name = 'Deleted'
      member.surname = 'User'
      member.pronouns = nil
      member.about_you = nil
      member.twitter = nil
      member.mobile = nil
      member.save(validate: false)
    end

    Rails.logger.info 'Member account deleted.'
  end
end
