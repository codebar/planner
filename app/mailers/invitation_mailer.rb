class InvitationMailer < ActionMailer::Base

  def invite session, member, invitation_token
    puts "in here"
    @member = member
    @session = session
    @invitation_token = invitation_token

    subject = "Post Rails Workshop sessions / HTML by Codebar - Wednesday Oct 23rd, 18:30"

    mail(mail_args(member, subject)) do |format|
      format.html { render :layout => "mailer" }
    end
  end

  private

  def load_attachments
    %w{logo.png twitter.png github.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  def mail_args(member, subject)
    { :from => "Codebar.io <meetings@codebar.io>",
      :to => member.email,
      :subject => subject }
  end
end
