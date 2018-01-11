module EmailHeaderHelper
  private

  def mail_args(member, subject, from_email = 'meetings@codebar.io', cc = '', bcc = '')
    { from: "codebar.io <#{from_email}>",
      to: member.email,
      cc: cc,
      bcc: bcc,
      subject: subject }
  end
end
