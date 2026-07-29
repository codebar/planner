RSpec.shared_examples 'email with social link colours' do
  it 'inlines social link background colours from the stylesheet' do
    send_email

    html = ActionMailer::Base.deliveries.last.html_part.body.decoded
    expect(html).to include('background-color: #2EB67D')
    expect(html).to include('background-color: #0077B5')
    expect(html).to include('background-color: #3B5998')
    expect(html).to include('background-color: #1daced')
    # premailer normalises #FF0000 to 'red'
    expect(html).to match(/background-color: (red|#FF0000)/i)
    expect(html).not_to include('/assets/email.css')
  end
end
