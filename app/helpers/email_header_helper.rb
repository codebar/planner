module EmailHeaderHelper
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
    return false if EmailValidator.valid?(email, mode: :strict)

    Rails.logger.warn("[EmailHeaderHelper] Invalid email for member_id=#{member_id}: #{email}")
    true
  end
end
