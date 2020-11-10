require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#contact_email' do
    it "returns the workshop chapter's email" do
      workshop = Fabricate(:workshop)
      expect(helper.contact_email(workshop: workshop)).to eq(workshop.chapter.email)
    end

    it 'returns hello@codebar.io when no workshop is set' do
      expect(helper.contact_email(workshop: nil)).to eq('hello@codebar.io')
    end
  end

  it '#twitter_url_for' do
    expect(twitter_url_for('Picard')).to eq('http://twitter.com/Picard')
  end

  describe '#number_to_currency' do
    it 'correctly formats a number to British pounds' do
      expect(helper.number_to_currency(20100)).to eq('£20,100')
    end
  end

  describe '#title and #get_title' do
    it 'sets page title with the given title name' do
      helper.title("Homapage")

      expect(helper.retrieve_title).to eq('Homapage | codebar.io')
    end

    it 'sets page title to codebar.io if no title is set' do
      helper.title

      expect(helper.retrieve_title).to eq('codebar.io')
    end
  end

  describe '#dot_markdown' do
    it 'renders CommonMark' do
      text = 'This is **bold** and this is _italic_'
      expected = '<p>This is <strong>bold</strong> and this is <em>italic</em></p>'
      expect(helper.dot_markdown(text)).to include(expected)
    end

    it 'removes potentially harmful HTML tags' do
      text = '<scrip>alert("Hi");</script>'
      expected = '<p><!-- raw HTML omitted -->alert(&quot;Hi&quot;);<!-- raw HTML omitted --></p>'
      expect(helper.dot_markdown(text)).to include(expected)
    end
  end
end
