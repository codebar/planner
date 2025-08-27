RSpec.feature 'A new student signs up', type: :feature do
  before do
    mock_github_auth
  end

  scenario 'A visitor can access signups through the landing page' do
    visit root_path
    click_on 'Join us as a student'
    click_on 'Join us as a student'

    accept_toc

    expect(page).to have_content('Thanks for signing up. Please fill in your details to complete the registration process.')
    expect(page).to have_current_path(edit_member_details_path(member_type: 'student'))
  end

  scenario 'A visitor must fill in all mandatory fields in order to sign up' do
    member = Fabricate(:member, name: nil, surname: nil, email: nil, about_you: nil)
    member.update(can_log_in: true)
    login member

    visit edit_member_details_path

    click_on 'Next'

    expect(page).to have_content "First name can't be blank"
    expect(page).to have_content "Surname can't be blank"
    expect(page).to have_content "Email address can't be blank"
    expect(page).to have_content "About you can't be blank"
    expect(page).to have_content "You must select at least one option"
  end

  scenario 'A new member details are successfully captured' do
    visit new_member_path
    click_on 'Join us as a coach'

    accept_toc

    fill_in 'member_pronouns', with: 'she'
    fill_in 'member_name', with: 'Jane'
    fill_in 'member_surname', with: 'Doe'
    fill_in 'member_email', with: 'jane@codebar.io'
    fill_in 'member_about_you', with: Faker::Lorem.paragraph
    check 'Vegan'
    check 'Other'
    fill_in 'Other dietary restrictions', with: 'peanut allergy'
    find('#how_you_found_us_from-a-friend').click
    fill_in 'member_how_you_found_us_other_reason', with: 'found on a poster', id: true
    click_on 'Next'

    expect(page).to have_current_path(step2_member_path)

    click_on 'Done'

    expect(page).to have_content('Pronouns')
    expect(page).to have_content('she')
    expect(page).to have_content('Jane Doe')
    expect(page).to have_link('jane@codebar.io')
    expect(page).to have_selector('.badge', text: 'Vegan')
    expect(page).to have_selector('.badge', text: 'Peanut allergy')
  end

  scenario 'Picking a mailing list on step 2 subscribes you to that list' do
    member = Fabricate(:member)
    group = Fabricate(:group)

    login member
    member.update(can_log_in: true)

    visit step2_member_path
    expect(page).to have_current_path(step2_member_path)

    click_button group.chapter.name
    click_on 'Done'

    expect(page).to have_link("#{group.name} (#{group.chapter.name})", href: "/#{group.chapter.slug}")
  end
end
