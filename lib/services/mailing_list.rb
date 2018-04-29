class MailingList
  attr_reader :list_id

  def initialize(list_id)
    @list_id = list_id
  end

  def subscribe(email, first_name, last_name)
    return true unless Rails.env.production?
    client.lists.subscribe(id: list_id,
                           email: { email: email },
                           merge_vars: { FNAME: first_name, LNAME: last_name },
                           double_optin: false,
                           update_existing: true)
  end

  def unsubscribe(email)
    return true unless Rails.env.production?
    client.lists.unsubscribe(id: list_id,
                             email: { email: email },
                             send_notify:  false)
  end

  private

  def client
    @client ||= Gibbon::API.new
  end
end
