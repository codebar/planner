class MemberSignupMailer < ActionMailer::Base
  default from: "welcome@codebar.io"

  def welcome_email(member)
    mail(
      to: member.email,
      subject: 'Welcome to Codebar'
    )
  end
end
