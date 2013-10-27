class InvitationMailer < ActionMailer::Base

  def invite sessions, member, invitation
    @session = sessions
    @member = member
    @invitation = invitation

    load_attachments

    subject = "HTML by Codebar - Wednesday Oct 30th, 18:30"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  private

  def load_attachments
    %w{logo.png unboxed.jpg}.each do |image|
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
