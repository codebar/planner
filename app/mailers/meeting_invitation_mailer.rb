class MeetingInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite meeting, member
    set_vars

    subject = "You are invited to codebar's #{@meeting.name} on #{humanize_date(@meeting.date_and_time)}"
    mail(mail_args(@member, subject)) do |format|
      format.html
    end
  end

  def attending meeting, member, invitation
    set_vars

    subject = "See you at #{@meeting.name} on #{humanize_date(@meeting.date_and_time)}"
    mail(mail_args(@member, subject)) do |format|
      format.html
    end
  end

  def approve_from_waitlist meeting, member, invitation
    set_vars

    subject = "A spot opened up for #{@meeting.name} on #{humanize_date(@meeting.date_and_time)}"
    mail(mail_args(@member, subject)) do |format|
      format.html
    end
  end

  def attendance_reminder meeting, member
    set_vars

    subject = "Reminder: You have a spot for #{@meeting.name} on #{humanize_date(@meeting.date_and_time)}"
    mail(mail_args(@member, subject)) do |format|
      format.html
    end
  end

  private

  def set_vars
    @member = member
    @meeting = meeting
    @host_address = AddressDecorator.new(@meeting.venue.address)
    @cancellation_url = meeting_url(@meeting)
  end
end
