class WorkshopInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student(workshops, member, invitation)
    @workshop = WorkshopPresenter.new(workshops)
    @member = member
    @invitation = invitation

    subject = "Workshop Invitation #{humanize_date(@workshop.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, 'no-reply@codebar.io')) do |format|
      format.html
    end
  end

  def invite_coach(workshops, member, invitation)
    @workshop = workshops
    @member = member
    @invitation = invitation

    subject = "Workshop Coach Invitation #{humanize_date(@workshop.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, 'no-reply@codebar.io')) do |format|
      format.html
    end
  end

  def attending(workshops, member, invitation, waiting_list = false)
    @workshop = WorkshopPresenter.new(workshops)
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = member
    @invitation = invitation
    @waiting_list = waiting_list

    subject = "Attendance Confirmation for #{humanize_date(@workshop.date_and_time, with_time: true)}"

    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: WorkshopCalendar.new(workshops).calendar.to_ical }

    mail(mail_args(member, subject, @workshop.chapter.email)) do |format|
      format.html
    end
  end

  def change_of_details(workshops, sponsor, member, invitation, title = 'Change of details')
    @workshop = workshops
    @sponsor = sponsor
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = member
    @invitation = invitation

    subject = "#{title}: #{@workshop.title} by codebar - #{humanize_date(@workshop.date_and_time, with_time: true)}"

    mail(mail_args(member, subject, @workshop.chapter.email)) do |format|
      format.html
      format.html { render layout: 'email' }
    end
  end

  def attending_reminder(workshop, member, invitation)
    @workshop = WorkshopPresenter.new(workshop)
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = member
    @invitation = invitation

    subject = "Workshop Reminder #{humanize_date(@workshop.date_and_time, with_time: true)}"
    mail(mail_args(member, subject, @workshop.chapter.email)) do |format|
      format.html
    end
  end

  def waiting_list_reminder(workshop, member, invitation)
    @workshop = WorkshopPresenter.new(workshop)
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = member
    @invitation = invitation

    subject = "Reminder: you're on the codebar waiting list (#{humanize_date(@workshop.date_and_time, with_time: true)})"
    mail(mail_args(member, subject, @workshop.chapter.email)) do |format|
      format.html
    end
  end

  def notify_waiting_list(invitation)
    @workshop = invitation.workshop
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = invitation.member
    @invitation = invitation

    subject = 'A spot just became available'

    mail(mail_args(member, subject, @workshop.chapter.email)) do |format|
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
