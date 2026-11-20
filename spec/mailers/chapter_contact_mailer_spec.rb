require 'rails_helper'

RSpec.describe ChapterContactMailer do
  let(:chapter) { Fabricate(:chapter) }
  let(:recipient) { Fabricate(:member) }

  it 'sanitizes message HTML and renders it using the app font stack' do
    message = '<p><strong>Hello</strong> <a href="javascript:alert(1)" onclick="alert(1)">there</a></p>' \
              '<script>alert("xss")</script>'
    email = described_class.with(chapter:, recipient:, subject: 'Update', message:).contact.deliver_now
    html = email.html_part.body.decoded

    expect(html).to include('font-family: system-ui')
    expect(html).to include('<strong>Hello</strong>')
    expect(html).not_to include('<script>')
    expect(html).not_to include('onclick')
    expect(html).not_to include('javascript:')
  end
end
