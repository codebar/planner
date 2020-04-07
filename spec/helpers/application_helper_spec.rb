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
end
