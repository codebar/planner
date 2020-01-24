require 'spec_helper'

RSpec.feature 'Subscribing to the newsletter', type: :feature do
  before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '42',
      credentials: { token: 'Fake token' },
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    )
  end

  context 'A new member' do
    scenario 'is subscribed to the newsletter by default' do
      mailing_list = double(:mailing_list)
      expect(MailingList).to receive(:new).and_return(mailing_list)
      expect(mailing_list).to receive(:subscribe).with('jane@codebar.io', 'Jane', 'Doe')

      visit new_member_path
      click_on 'Sign up as a coach'

      accept_toc

      fill_in 'member_pronouns', with: 'she'
      fill_in 'member_name', with: 'Jane'
      fill_in 'member_surname', with: 'Doe'
      fill_in 'member_email', with: 'jane@codebar.io'
      fill_in 'member_about_you', with: Faker::Lorem.paragraph

      click_on 'Next'
    end

    scenario 'can opt out of the newsletter' do
      mailing_list = double(:mailing_list)
      expect(MailingList).to receive(:new).and_return(mailing_list)
      expect(mailing_list).to receive(:unsubscribe).with('jane@codebar.io')

      visit new_member_path
      click_on 'Sign up as a coach'

      accept_toc

      fill_in 'member_pronouns', with: 'she'
      fill_in 'member_name', with: 'Jane'
      fill_in 'member_surname', with: 'Doe'
      fill_in 'member_email', with: 'jane@codebar.io'
      fill_in 'member_about_you', with: Faker::Lorem.paragraph

      uncheck 'newsletter'

      click_on 'Next'
    end
  end
end
