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

  scenario 'can access and view the corporate support page' do
    visit corporate_support_path

    expect(page).to have_css('h1', text: 'Corporate partnership')
    expect(page).to have_link('Host a workshop', href: 'mailto:hello@codebar.io?subject=I%27d%20like%20to%20host%20a%20workshop')
    expect(page).to have_link('Partner with codebar', href: 'mailto:hello@codebar.io?subject=I%27d%20like%20to%20create%20a%20longterm%20partnership%20with%20codebar')
    expect(page).to have_link('Donate to codebar', href: 'https://codebar.enthuse.com/donate#!/')
  end

  scenario 'can see the why partner section' do
    visit corporate_support_path

    expect(page).to have_css('h2', text: 'Why partner with us?')
    expect(page).to have_css('h5', text: '👥 SUPPORT YOUR PEOPLE')
  end

  scenario 'can see the did you know section' do
    visit corporate_support_path

    expect(page).to have_css('h2', text: 'Did you know…')
    expect(page).to have_text('27,500+ people in the codebar community')
    expect(page).to have_link('Still unsure? See more of our impact here', href: 'https://impact-report.codebar.io/', class: 'btn-pink')
  end

  scenario 'can see the support us your way section' do
    visit corporate_support_path

    expect(page).to have_css('h2', text: 'Support us your way')
    expect(page).to have_link('Fundraise for codebar', href: fundraise_path)
    expect(page).to have_link('Volunteer', href: volunteer_path)
  end

  scenario 'can access page not found' do
    visit '/does_not_exist'

    expect(page).to have_text('Page not found')
  end
end
