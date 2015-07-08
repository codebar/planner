module EmailHeaderHelper
  private

  def load_attachments
    %w{logo.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  def mail_args(member, subject, cc = '')
    { :from => "codebar.io <meetings@codebar.io>",
      :to => member.email,
      :cc => cc,
      :subject => subject }
  end
end
