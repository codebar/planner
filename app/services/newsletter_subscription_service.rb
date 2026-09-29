# frozen_string_literal: true

# Subscribes every member with a kept (non-tombstoned) subscription to the
# newsletter mailing list, run by the mailing_list:subscribe_active_members
# rake task, which reads ENV['NEWSLETTER_ID'] and passes it in; tests inject
# a fake value.
class NewsletterSubscriptionService
  def self.call(newsletter_id:)
    new(newsletter_id:).call
  end

  def initialize(newsletter_id:)
    @newsletter_id = newsletter_id
  end

  def call
    newsletter = Services::MailingList.new(@newsletter_id)

    # Kept subscriptions only: tombstoned rows record past periods, not current subscribers.
    members.each do |member|
      member.update(opt_in_newsletter_at: Time.zone.now)
      newsletter.subscribe(member.email, member.name, member.surname)
    end
  end

  private

  def members
    Member.joins(:subscriptions).where(subscriptions: { discarded_at: nil }).distinct
  end
end
