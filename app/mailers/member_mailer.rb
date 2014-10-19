class MemberMailer < ActionMailer::Base
  include EmailHeaderHelper

  def welcome(member)
    if member.student?
      welcome_student member
    elsif member.coach?
      welcome_coach member
    end
  end

  def welcome_student(member)
    @member = member
    subject = "Welcome to Codebar!"

    mail(mail_args(member, subject)) do |format|
      format.html { render 'welcome_student' }
    end
  end

  def welcome_coach(member)
    @member = member
    subject = "Welcome to Codebar!"

    mail(mail_args(member, subject)) do |format|
      format.html { render 'welcome_coach' }
    end
  end
end
