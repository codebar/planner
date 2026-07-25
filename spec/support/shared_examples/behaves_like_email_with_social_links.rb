RSpec.shared_examples 'email with social link colours' do
  it 'inlines social link background colours and embeds the stylesheet' do
    send_email

    html = ActionMailer::Base.deliveries.last.body.encoded
    ['#2EB67D', '#0077B5', '#3B5998', '#1daced', '#FF0000'].each do |colour|
      expect(html).to include("background-color: #{colour}")
    end
    expect(html).not_to include('/assets/email.css')
    expect(html).to match(/<style type=(?:3D)?"text\/css"/)
  end
end
