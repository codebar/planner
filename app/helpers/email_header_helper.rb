module EmailHeaderHelper
  private

  def mail_args(member, subject, from_email="meetings@codebar.io", cc="")
    { :from => "codebar.io <#{from_email}>",
      :to => member.email,
      :cc => cc,
      :subject => subject }
  end
end
