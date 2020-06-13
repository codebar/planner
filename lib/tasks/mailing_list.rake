namespace :mailing_list do
  require 'services/mailing_list'

  desc 'Subscribe all active members to newsletter mailing list'
  task subscribe_active_members: :environment do
    newsletter_id = ENV['NEWSLETTER_ID'] || Rails.logger.info('NEWSLETTER_ID not set. Aborting task') && abort

    members = Member.includes(:subscriptions).where.not('subscriptions.member_id' => nil).uniq
    newsletter = MailingList.new(newsletter_id)

    members.each do |member|
      member.update(opt_in_newsletter_at: Time.zone.now)
      newsletter.subscribe(member.email, member.name, member.surname)
    end
  end
end
