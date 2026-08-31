module EmailDelivery
  extend ActiveSupport::Concern

  private

  # The mailer action name distinguishes which email a logged row is for.
  # find_or_create_by keeps a replayed delivery (e.g. a retried job) from
  # raising on the unique index after the email has already gone out.
  def log_sent_email
    member = params[:member]
    return unless member
    return unless @_mail_was_called

    MemberEmailDelivery.find_or_create_by!(member:, email_type: action_name) do |delivery|
      delivery.subject = mail.subject
      delivery.body = mail.html_part ? mail.html_part.body.to_s : mail.body.to_s
      delivery.to = Array(mail.to)
      delivery.cc = Array(mail.cc)
      delivery.bcc = Array(mail.bcc)
    end
  end
end
