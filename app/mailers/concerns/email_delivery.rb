module EmailDelivery
  extend ActiveSupport::Concern

  private

  def log_sent_email
    member = params[:member]
    return unless member

    MemberEmailDelivery.create!(
      member: member,
      subject: mail.subject,
      body: mail.body.to_s,
      to: Array(mail.to),
      cc: Array(mail.cc),
      bcc: Array(mail.bcc)
    )
  end
end
