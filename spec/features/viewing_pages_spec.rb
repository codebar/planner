require 'spec_helper'

feature 'A visitor to the website' do
  scenario 'can access and view the cookie policy' do
    visit root_path

    click_on 'Cookie Policy'
    expect(page).to have_content('Cookies are small pieces of text used to store information on web browsers.')
  end

  scenario 'can access and view the privacy policy' do
    visit root_path

    click_on 'Privacy Policy'
    expect(page).to have_content('Your privacy means a lot to us')
  end
end
