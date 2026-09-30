require 'rails_helper'

RSpec.feature 'A visitor to the website' do
  scenario 'can access and view the cookie policy' do
    visit root_path

    click_on 'Cookie Policy'
    expect(page).to have_text('Cookies are small pieces of text used to store information on web browsers.')
  end

  scenario 'can access and view the privacy policy' do
    visit root_path

    click_on 'Privacy Policy'
    expect(page).to have_text('Your privacy means a lot to us')
  end

  scenario 'can access page not found' do
    visit '/does_not_exist'

    expect(page).to have_text('Page not found')
  end

  scenario 'can access and view the fundraise page' do
    visit fundraise_path

    expect(page).to have_css('h1', text: 'Take on a challenge for codebar')
    expect(page).to have_text('Barcelona Marathon')
    expect(page).to have_text('HOKA Hackney Half')
    expect(page).to have_text('Southampton Running Festival 10k')
    expect(page).to have_text('Great South Run 2027')
    expect(page).to have_no_css('iframe')
  end

  scenario 'every event card has a title, description and date' do
    visit fundraise_path

    within "[data-test='fundraising-events']" do
      expect(page).to have_css('.card').at_least(1)
      page.all('.card').each do |card|
        within card do
          expect(page).to have_css('h4', text: /\S/)
          expect(page).to have_css('p.card-text', text: /\S/)
          expect(page).to have_css('p.card-text.text-muted', text: /\d{2} \w{3} \d{4}/)
        end
      end
    end
  end

  scenario 'every event card can be enquired about by email' do
    visit fundraise_path

    within "[data-test='fundraising-events']" do
      expect(page).to have_css('.card').at_least(1)
      page.all('.card').each do |card|
        within card do
          expect(page).to have_link('Email us', href: 'mailto:hello@codebar.io')
        end
      end
    end
  end

  scenario 'visitors are invited to suggest their own challenge' do
    visit fundraise_path

    expect(page).to have_css('h2', text: 'Got your own challenge?')
  end

  scenario 'visitors are told why fundraising for codebar matters' do
    visit fundraise_path

    expect(page).to have_css('h2', text: 'Why fundraise for codebar?')
    expect(page).to have_text('All of our workshops and events are completely free for everyone who attends.')
  end

  scenario 'the impact of fundraising is shown in a row of three cards' do
    visit fundraise_path

    within "[data-test='fundraising-impact']" do
      expect(page).to have_css('.card').exactly(3).times
      page.all('.card').each do |card|
        within card do
          expect(page).to have_css('h5', text: /\S/)
          expect(page).to have_css('p.card-text', text: /\S/)
        end
      end
    end
  end

  scenario 'the impact cards quote the codebar community statistics' do
    visit fundraise_path

    within "[data-test='fundraising-impact']" do
      expect(page).to have_text('85% of codebar community members')
      expect(page).to have_text('73% of codebar students')
      expect(page).to have_text('Over 27,500 people across 36 global locations')
    end
  end
end
