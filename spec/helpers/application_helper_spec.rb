require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#contact_email' do
    it "returns the workshop chapter's email" do
      @workshop = Fabricate(:workshop)
      expect(helper.contact_email).to eq(@workshop.chapter.email)
    end

    it 'returns hello@codebar.io when no workshop is set' do
      expect(helper.contact_email).to eq('hello@codebar.io')
    end
  end

  it '#twitter_url_for' do
    expect(twitter_url_for('Picard')).to eq('http://twitter.com/Picard')
  end
end
