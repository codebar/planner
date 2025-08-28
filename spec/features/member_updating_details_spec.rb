RSpec.feature 'Update your details', type: :feature do
  before do
    mock_github_auth
  end

  scenario 'A member adds a dietary restriction' do
    member = Fabricate(:member)
    login member

    visit edit_member_path
    check 'Vegetarian'
    click_on 'Save'

    expect(page).to have_content('Your details have been updated.')
    expect(page).to have_selector(".badge", text: "Vegetarian")
  end

  scenario 'A member adds a custom dietary restriction' do
    member = Fabricate(:member)
    login member

    visit edit_member_path
    check 'Other'
    fill_in 'Other dietary restrictions', with: 'peanut allergy'
    click_on 'Save'

    expect(page).to have_content('Your details have been updated.')
    expect(page).to have_selector(".badge", text: 'Peanut allergy')
    member.reload
    expect(member.dietary_restrictions).to eq(['other'])
    expect(member.other_dietary_restrictions).to eq('peanut allergy')
  end

  scenario 'A member removes a dietary restriction' do
    member = Fabricate(:member, dietary_restrictions: ['vegetarian'])
    login member

    visit edit_member_path
    uncheck 'Vegetarian'
    click_on 'Save'

    expect(page).to have_content('Your details have been updated.')
    member.reload
    expect(member.dietary_restrictions).to be_empty
  end
end
