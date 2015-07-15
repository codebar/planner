class MemberMailer < ActionMailer::Base
  include EmailHeaderHelper

  def welcome(member)
    if member.student?
      welcome_student(member)
    elsif member.coach?
      welcome_coach(member)
    end
  end

  def welcome_for_subscription(subscription)
    member = subscription.member
    if subscription.student?
      welcome_student(member)
      member.received_student_welcome_email = true
    elsif subscription.coach?
      welcome_coach(member)
      member.received_coach_welcome_email = true
    end
    member.save
  end

  def welcome_student(member)
    @member = member
    subject = "How codebar works"

    mail(mail_args(member, subject)) do |format|
      format.html { render 'welcome_student' }
    end.deliver
  end

  def welcome_coach(member)
    @member = member
    subject = "How codebar works"

    mail(mail_args(member, subject)) do |format|
      format.html { render 'welcome_coach' }
    end.deliver
  end

  def eligibility_check(member)
    @member = member
    subject = "Eligibility confirmation"

    mail(mail_args(member, subject, 'hello@codebar.io')) do |format|
      format.html { render 'eligibility_check' }
    end.deliver
  end

  def attendance_warning(member)
    @member = member
    subject = "Attendance warning"

    mail(mail_args(member, subject, 'hello@codebar.io')) do |format|
      format.html { render 'attendance_warning' }
    end.deliver
  end
end
