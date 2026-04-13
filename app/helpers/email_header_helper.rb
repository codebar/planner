module EmailHeaderHelper
  EMAIL_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/

  private

  def mail_args(member, subject, from_email = 'meetings@codebar.io', cc = '', bcc = '')
    return nil if invalid_email?(member.email, member.id)

    { from: "codebar.io <#{from_email}>",
      to: member.email,
      cc: cc,
      bcc: bcc,
      subject: subject }
  end

  def invalid_email?(email, member_id)
    return false if email.present? && email.match?(EMAIL_REGEX)

    Rails.logger.warn("[EmailHeaderHelper] Invalid email for member_id=#{member_id}: #{email}")
    true
  end
end
