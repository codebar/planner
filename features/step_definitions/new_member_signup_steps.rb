When(/^a member signs up with no role$/) do
  visit root_path
  click_on 'Become a member'

  fill_in :member_name, with: credentials[:name]
  fill_in :member_surname, with: credentials[:surname]
  fill_in :member_email, with: credentials[:email]
  fill_in :member_twitter, with: credentials[:twitter]
  fill_in :member_about_you, with: credentials[:about_you]

  click_on 'Join'
end

Then(/^a confirmation email should be sent$/) do
  @mail = ActionMailer::Base.deliveries.last
  expect(@mail.to).to eq(['test@testmail.com'])
end

Then(/^the email subject should be correct$/) do
  expect(@mail.subject).to eq('Welcome to Codebar')
end

Then(/^the email body should be correct$/) do
  expect(@mail.subject).to eq('Welcome to Codebar')
end

Then(/^the member should be redirected to the homepage$/) do
  expect(current_path).to eq(root_path)
end

Then(/^the 'sign up' message should be displayed$/) do
  expect(page).to have_selector('.alert', text: "Thanks for signing up Name! You have not selected any roles so you won't be receiving any notifications. If you change your mind, send us an email at hello@codebar.io so we can change your settings.")
end

def credentials
  {
    name: 'Name',
    surname: 'Surname',
    email: 'test@testmail.com',
    twitter: '@twitter_name',
    about_you: 'This is all about me'
  }
end
