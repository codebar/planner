# frozen_string_literal: true

namespace :mailing_list do
  desc 'Subscribe all active members to newsletter mailing list'
  task subscribe_active_members: :environment do
    newsletter_id = ENV['NEWSLETTER_ID']
    if newsletter_id.blank?
      Rails.logger.info('NEWSLETTER_ID not set. Aborting task')
      abort
    end

    NewsletterSubscriptionService.call(newsletter_id:)
  end
end
