class SessionInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper

  def invite_student sessions, member, invitation
    @session = sessions
    @member = member
    @invitation = invitation

    subject = "Workshop Invitation for #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def invite_coach sessions, member, invitation
    @session = sessions
    @member = member
    @invitation = invitation

    subject = "Workshop Coach Invitation for #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def attending sessions, member, invitation

    @session = sessions
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "Attendance confirmation - #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html { render layout: "email" }
    end
  end

  def change_of_details sessions, sponsor, member, invitation, title="Change of details"
    @session = sessions
    @sponsor = sponsor
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "#{title}: #{@session.title} by Codebar - #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html { render layout: "email" }
    end
  end

  def remind_student session, member, invitation
    @session = session
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "Reminder for #{@session.title} by Codebar - #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html { render layout: "email" }
    end
  end

  def spots_available session, member, invitation
    @session = session
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "Spots available for #{@session.title} by Codebar - #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html { render layout: "email" }
    end
  end

  private

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
