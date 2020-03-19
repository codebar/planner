require 'spec_helper'

RSpec.describe 'Humanize' do
  before do
    travel_to Time.local(2020, 1, 15, 12, 30)
  end

  it "humanizes date without time or year" do
    expect(I18n.l(Time.zone.now, format: :_humanize_date))
      .to eq "Wed, 15th January"
  end

  it "humanizes date without time but with year" do
    expect(I18n.l(Time.zone.now, format: :_humanize_date_with_year))
      .to eq "Wed, 15th January 2020"
  end

  it "humanizes date with time but not year" do
    expect(I18n.l(Time.zone.now, format: :_humanize_date_with_time))
      .to eq "Wed, 15th January at 12:30"
  end

  it "humanizes date with time and year" do
    expect(I18n.l(Time.zone.now, format: :_humanize_date_with_year_with_time))
      .to eq "Wed, 15th January 2020 at 12:30"
  end

  after do
    travel_back
  end
end
