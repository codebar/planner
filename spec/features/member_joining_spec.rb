require 'spec_helper'

feature 'a member can sign up' do

  scenario 'when they fill in all the required details' do
    visit root_path
    click_on "Become a member"

    fill_in "Name", with: Faker::Name.first_name
    fill_in "Surname", with: Faker::Name.last_name

    fill_in "Email", with: Faker::Internet.email
    fill_in "Twitter", with: Faker::Name.first_name

    fill_in "Tell us a little bit about yourself", with: Faker::Lorem.paragraph

    click_on "Join Codebar.io"
  end
end

