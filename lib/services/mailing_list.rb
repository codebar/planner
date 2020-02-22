class MailingList
  SUBSCRIBED = 'subscribed'.freeze
  MEMBER_EXISTS = 'Member Exists'.freeze

  attr_reader :list_id

  def initialize(list_id)
    @list_id = list_id
  end

  def subscribe(email, first_name, last_name)
    return if disabled?

    begin
      client.lists(list_id).members
            .create(body: { email_address: email,
                            status: 'subscribed',
                            merge_fields: { FNAME: first_name, LNAME: last_name } })
    rescue Gibbon::MailChimpError => e
      reactivate_subscription(email, first_name, last_name) if e.title.eql?(MEMBER_EXISTS)
    end
  end
  handle_asynchronously :subscribe

  def unsubscribe(email)
    return if disabled?

    client.lists(list_id).members(md5_hashed_email_address(email))
          .update(body: { status: 'unsubscribed' })
  end
  handle_asynchronously :unsubscribe

  def reactivate_subscription(email, first_name, last_name)
    return if disabled?

    client.lists(list_id).members(md5_hashed_email_address(email))
          .upsert(body: { email_address: email,
                          status: 'subscribed',
                          merge_fields: { FNAME: first_name, LNAME: last_name } })
  end
  handle_asynchronously :reactivate_subscription

  def subscribed?(email)
    return if disabled?

    info = client.lists(list_id).members(md5_hashed_email_address(email)).retrieve
    info.body[:status].eql?(SUBSCRIBED)
  rescue Gibbon::MailChimpError
    false
  end

  private

  def client
    @client ||= Gibbon::Request.new
  end

  def md5_hashed_email_address(email)
    require 'digest'
    Digest::MD5.hexdigest(email.downcase)
  end

  def disabled?
    !ENV['MAILCHIMP_KEY']
  end
end
