require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#humanize_date' do
    before do
      travel_to Time.local(2020, 1, 15, 12, 30)
    end

    # humainize_week_day_with_date
    it "humanizes date without time or year" do
      expect(humanize_date(Time.zone.now, with_time: false, with_year: false))
        .to eq "Wed, 15th January"
    end

    # humainize_week_day_with_date
    it "humanizes date without time but with year" do
      expect(humanize_date(Time.zone.now, with_time: false, with_year: true))
        .to eq "Wed, 15th January 2020"
    end


    it "humanizes date with time but not year" do
      expect(humanize_date(Time.zone.now, with_time: true, with_year: false))
        .to eq "Wed, 15th January at 12:30"
    end

    it "humanizes date with time and year" do
      expect(humanize_date(Time.zone.now, with_time: true, with_year: true))
        .to eq "Wed, 15th January 2020 at 12:30"
    end

    after do
      travel_back
    end
  end

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
