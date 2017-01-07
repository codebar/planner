require 'spec_helper'

feature 'A new member signs up', js: false do
  before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: '42',
      credentials: {token: "Fake token"},
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    })
  end

  scenario 'Member visits tutorial page before completing step 1 of registration' do
    member = Fabricate(:member)
    member.update(can_log_in: :true)
    login member
    visit step1_member_path

    within('.top-bar') do
      click_on 'Tutorials'
    end

    expect(current_path).to eq(step1_member_path)
  end
end
