class MemberMailer < ApplicationMailer
  include EmailHeaderHelper
  include EmailDelivery

  after_deliver :log_sent_email, only: [:chaser]

  def chaser
    @member = params[:member]
    subject = "It’s been a while, how are you doing? ♥️"
    mail_to_member(@member, subject, 'hello@codebar.io', 'hello@codebar.io') do |format|
      format.html {render 'three_month_chaser'}
    end
  end

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
    subject = 'How codebar works'

    mail_to_member(member, subject, 'hello@codebar.io') do |format|
      format.html { render 'welcome_student' }
    end
  end

  def welcome_coach(member)
    @member = member
    subject = 'How codebar works'

    mail_to_member(member, subject, 'hello@codebar.io') do |format|
      format.html { render 'welcome_coach' }
    end
  end

  def eligibility_check(member, sender = 'hello@codebar.io')
    @member = member
    subject = 'Eligibility confirmation'

    mail_to_member(member, subject, 'hello@codebar.io', 'hello@codebar.io', sender) do |format|
      format.html { render 'eligibility_check' }
    end
  end

  def attendance_warning(member, sender = 'hello@codebar.io')
    @member = member
    subject = 'Attendance warning'

    # TODO: .deliver here causes double-delivery because callers also call .deliver_now
    mail_to_member(member, subject, 'hello@codebar.io', 'hello@codebar.io', sender) do |format|
      format.html { render 'attendance_warning' }
    end.deliver
  end

  def ban(member, ban)
    @member = member
    @reason = ban.reason
    @expiry_date = I18n.l(ban.expires_at, format: :default)
    @ban = ban

    # TODO: .deliver here causes double-delivery because callers also call .deliver_now
    mail_to_member(member, @reason, 'hello@codebar.io', 'hello@codebar.io') do |format|
      format.html { render 'ban' }
    end.deliver
  end
end
