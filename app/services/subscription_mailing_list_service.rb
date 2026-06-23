class SubscriptionMailingListService
  def self.subscribe(subscription)
    new.subscribe(subscription)
  end

  def self.unsubscribe(subscription)
    new.unsubscribe(subscription)
  end

  def subscribe(subscription)
    list = mailing_list(subscription.group.mailing_list_id)
    list.subscribe(subscription.member.email, subscription.member.name, subscription.member.surname)
  end

  def unsubscribe(subscription)
    list = mailing_list(subscription.group.mailing_list_id)
    list.unsubscribe(subscription.member.email)
  end

  private

  def mailing_list(list_id)
    @mailing_lists ||= {}
    @mailing_lists[list_id] ||= Services::MailingList.new(list_id)
  end
end
