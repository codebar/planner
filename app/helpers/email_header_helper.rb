module EmailHeaderHelper
  private

  def load_attachments
    %w{logo.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  def mail_args(member, subject)
    { :from => "codebar.io <meetings@codebar.io>",
      :to => member.email,
      :subject => subject }
  end
end