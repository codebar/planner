module EmailHeaderHelper
  private

  def mail_args(member, subject, cc = '')
    { :from => "codebar.io <meetings@codebar.io>",
      :to => member.email,
      :cc => cc,
      :subject => subject }
  end
end
