module EmailHelpers
  # Mails the test-delivery path collected for a recipient (a Member or an
  # address). The test queue adapter is delayed_job with Delayed::Worker.delay_jobs
  # set to false in test, so deliver_later delivers immediately and mail lands in
  # ActionMailer::Base.deliveries.
  def delivered_emails_to(recipient)
    address = recipient.respond_to?(:email) ? recipient.email : recipient
    ActionMailer::Base.deliveries.select { |mail| mail.to.include?(address) }
  end

  # Decoded text/html body of a delivered Mail::Message. The invitation mailers
  # send multipart/mixed > multipart/alternative > text/html, so the root
  # mail.body.decoded is empty and the html part must be read directly.
  def email_html(mail)
    parts = mail.parts.flat_map { |part| part.multipart? ? part.parts : [part] }
    parts.find { |part| part.content_type.match?('text/html') }&.body&.decoded
  end
end
