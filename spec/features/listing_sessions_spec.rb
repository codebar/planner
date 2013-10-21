require 'spec_helper'

feature 'session listing' do

  let(:date_and_time) { DateTime.now+1.week }
  let!(:session) { Sessions.create title: "HTML by Codebar",
                  description: "Let's work together through out mini HTML workshop",
                  date_and_time: date_and_time }

  scenario 'when i visit the page, i can view a list with all the sesions' do
    pending("on hold until we finish the home page design")
    visit root_path

    expect(page).to have_content session.title
  end
end
