class SessionInvitationMailer < ActionMailer::Base
  layout 'email'

  def invite_student sessions, member, invitation
    @session = sessions
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "#{@session.title} by Codebar - #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
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
      format.html
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
      format.html
    end
  end

  private

  def load_attachments
    %w{logo.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  def mail_args(member, subject)
    { :from => "Codebar.io <meetings@codebar.io>",
      :to => member.email,
      :subject => subject }
  end

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
