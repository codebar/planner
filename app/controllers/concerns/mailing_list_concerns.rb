module MailingListConcerns
  extend ActiveSupport::Concern

  included do
    require 'services/mailing_list'

    include InstanceMethods
  end

  module InstanceMethods
    def subscribe_to_newsletter(member)
      member.update(opt_in_newsletter_at: Time.zone.now)
      Services::MailingList.new(ENV['NEWSLETTER_ID']).subscribe(member.email,
                                                                member.name,
                                                                member.surname)
    end

    def unsubscribe_from_newsletter(member)
      member.update(opt_in_newsletter_at: nil)
      Services::MailingList.new(ENV['NEWSLETTER_ID']).unsubscribe(member.email)
    end
  end
end
