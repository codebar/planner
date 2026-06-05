module EmailHeaderHelper
  class SkippedEmail
    def deliver_now; self; end
    def deliver_later; self; end
    def deliver; self; end
    def deliver!; self; end
  end

  private

  def mail_to_member(member, subject, from_email = 'meetings@codebar.io', cc = '', bcc = '', &block)
    if invalid_email?(member.email, member.id)
      Rails.logger.info(
        "[#{self.class.name}] Skipped email to member #{member.id}: " \
        "invalid email #{member.email.inspect}"
      )
      return SkippedEmail.new
    end

    mail(from: "codebar.io <#{from_email}>",
         to: member.email,
         cc: cc,
         bcc: bcc,
         subject: subject,
         &block)
  end

  def invalid_email?(email, member_id)
    return false if EmailValidator.valid?(email, mode: :strict)

    Rails.logger.warn("[EmailHeaderHelper] Invalid email for member_id=#{member_id}: #{email}")
    true
  end
end
