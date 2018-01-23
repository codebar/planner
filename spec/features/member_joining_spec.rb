require 'spec_helper'

feature 'A new student signs up', js: false do
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

  scenario 'A visitor can access signups through the landing page' do
    visit root_path
    click_on 'Sign up as a student'
    click_on 'I understand and meet the eligibility criteria. Sign me up as a student'
    expect(page).to have_current_path(step1_member_path(member_type: 'student'))
  end

  scenario 'A visitor must fill in all mandatory fields in order to sign up', js: true do
    member = Fabricate(:member, name: nil, surname: nil, email: nil, about_you: nil)
    member.update(can_log_in: true)
    login member

    visit step1_member_path

    click_on 'Next'

    expect(page).to have_selector('.member_name .error')
    expect(page).to have_selector('.member_surname .error')
    expect(page).to have_selector('.member_email .error')
    expect(page).to have_selector('.member_about_you .error')
  end

  scenario 'A new member details are succesfuly captured' do
    visit new_member_path
    click_on 'Sign up as a coach'

    fill_in 'member_pronouns', with: 'she'
    fill_in 'member_name', with: 'Jane'
    fill_in 'member_surname', with: 'Doe'
    fill_in 'member_email', with: 'jane@codebar.io'
    fill_in 'member_about_you', with: Faker::Lorem.paragraph
    click_on 'Next'

    expect(page).to have_current_path(step2_member_path)

    click_on 'Done'

    expect(page).to have_content('Pronouns')
    expect(page).to have_content('she')
    expect(page).to have_content('Jane Doe')
    expect(page).to have_link('jane@codebar.io')
  end


  scenario 'Picking a mailing list on step 2 subscribes you to that list' do
    member = Fabricate(:member)
    group = Fabricate(:group)
    coach_group = Fabricate(:coaches)

    login member
    member.update(can_log_in: true)

    visit step2_member_path
    expect(page).to have_current_path(step2_member_path)

    click_button group.chapter.name
    click_on 'Done'

    expect(page).to have_link("#{group.name} (#{group.chapter.name})", href: "/#{group.chapter.slug}")
  end
end
