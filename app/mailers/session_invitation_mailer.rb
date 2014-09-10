class SessionInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student sessions, member, invitation
    @session = sessions
    @workshop = WorkshopPresenter.new(sessions)
    @member = member
    @invitation = invitation

    subject = "Workshop Invitation #{humanize_date_with_time(@session.date_and_time, @session.time)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def invite_coach sessions, member, invitation
    @session = sessions
    @member = member
    @invitation = invitation

    subject = "Workshop Coach Invitation #{humanize_date_with_time(@session.date_and_time, @session.time)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def attending sessions, member, invitation, waiting_list=false
    @session = sessions
    @workshop = WorkshopPresenter.new(sessions)
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation
    @waiting_list = waiting_list

    subject = "Attendance Confirmation for #{humanize_date_with_time(@session.date_and_time, @session.time)}"

    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: WorkshopCalendar.new(@session).calendar.to_ical }


    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def change_of_details sessions, sponsor, member, invitation, title="Change of details"
    @session = sessions
    @sponsor = sponsor
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "#{title}: #{@session.title} by Codebar - #{humanize_date_with_time(@session.date_and_time, @session.time)}"

    mail(mail_args(member, subject)) do |format|
      format.html { render layout: "email" }
    end
  end

  def reminder session, member, invitation
    @session = session
    @workshop = WorkshopPresenter.new(session)
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    subject = "Workshop Reminder #{humanize_date_with_time(@session.date_and_time, @session.time)}"
    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def notify_waiting_list(invitation)
    @session = invitation.sessions
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = invitation.member
    @invitation = invitation

    subject = "A spot just became available"

    mail(mail_args(@member, subject)) do |format|
      format.html
    end
  end

  private

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
