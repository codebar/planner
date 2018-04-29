class SessionInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student(sessions, member, invitation)
    @session = sessions
    @workshop = WorkshopPresenter.new(sessions)
    @member = member
    @invitation = invitation

    subject = "Workshop Invitation #{humanize_date(@session.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, 'no-reply@codebar.io')) do |format|
      format.html
    end
  end

  def invite_coach(sessions, member, invitation)
    @session = sessions
    @member = member
    @invitation = invitation

    subject = "Workshop Coach Invitation #{humanize_date(@session.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, 'no-reply@codebar.io')) do |format|
      format.html
    end
  end

  def attending(sessions, member, invitation, waiting_list = false)
    @session = sessions
    @workshop = WorkshopPresenter.new(sessions)
    @host_address = AddressPresenter.new(@session.host.address)
    @member = member
    @invitation = invitation
    @waiting_list = waiting_list

    subject = "Attendance Confirmation for #{humanize_date(@session.date_and_time, with_time: true)}"

    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: WorkshopCalendar.new(@session).calendar.to_ical }

    mail(mail_args(member, subject, @session.chapter.email)) do |format|
      format.html
    end
  end

  def change_of_details(sessions, sponsor, member, invitation, title = 'Change of details')
    @session = sessions
    @sponsor = sponsor
    @host_address = AddressPresenter.new(@session.host.address)
    @member = member
    @invitation = invitation

    subject = "#{title}: #{@session.title} by codebar - #{humanize_date(@session.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, @session.chapter.email)) do |format|
      format.html
      format.html { render layout: 'email' }
    end
  end

  def attending_reminder(session, member, invitation)
    @session = session
    @workshop = WorkshopPresenter.new(session)
    @host_address = AddressPresenter.new(@session.host.address)
    @member = member
    @invitation = invitation

    subject = "Workshop Reminder #{humanize_date(@session.date_and_time, with_time: true)}"
    mail(mail_args(member, subject, @session.chapter.email)) do |format|
      format.html
    end
  end

  def waiting_list_reminder(session, member, invitation)
    @session = session
    @workshop = WorkshopPresenter.new(session)
    @host_address = AddressPresenter.new(@session.host.address)
    @member = member
    @invitation = invitation

    subject = "Reminder: you're on the codebar waiting list (#{humanize_date(@session.date_and_time, with_time: true)})"
    mail(mail_args(member, subject, @session.chapter.email)) do |format|
      format.html
    end
  end

  def notify_waiting_list(invitation)
    @session = invitation.workshop
    @host_address = AddressPresenter.new(@session.host.address)
    @member = invitation.member
    @invitation = invitation

    subject = 'A spot just became available'

    mail(mail_args(member, subject, @session.chapter.email)) do |format|
      format.html
    end
  end

  private

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
