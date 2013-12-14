class MemberSignupMailer < ActionMailer::Base
  layout 'email'

  def welcome_email(member)
    @member = member

    load_attachments

    mail(mail_args(member)) do |format|
      format.html
    end
  end

  private

  def mail_args(member)
    { :from => "Codebar.io <welcome@codebar.io>",
      :to => member.email,
      :subject => 'Welcome to Codebar' }
  end

  def load_attachments
    %w{logo.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
