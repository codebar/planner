class ContactMailingListService
  def self.sync(contact)
    new.sync(contact)
  end

  def sync(contact)
    case contact.mailing_list_consent
    when true then subscribe(contact)
    when false then unsubscribe(contact)
    end
  end

  private

  def subscribe(contact)
    mailing_list.subscribe(contact.email, contact.name, contact.surname)
    ContactMailer.subscription_notification(contact).deliver_now
  end

  def unsubscribe(contact)
    mailing_list.unsubscribe(contact.email)
  end

  def mailing_list
    @mailing_list ||= Services::MailingList.new(ENV['SPONSOR_NEWSLETTER_ID'])
  end
end
