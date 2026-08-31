module EmailDelivery
  extend ActiveSupport::Concern

  private

  def log_sent_email
    member = params[:member]
    return unless member
    return unless @_mail_was_called

    MemberEmailDelivery.create!(
      member: member,
      subject: mail.subject,
      # premailer-rails' interceptor empties the body container and moves the
      # content into text/html parts during delivery, so read the html part
      body: mail.html_part ? mail.html_part.body.to_s : mail.body.to_s,
      to: Array(mail.to),
      cc: Array(mail.cc),
      bcc: Array(mail.bcc)
    )
  end
end
