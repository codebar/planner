module MemberHelpers

  def fill_in_member_details name=Faker::Name.first_name
    visit root_path
    click_on "Become a member"

    fill_in "Name", with: name
    fill_in "Surname", with: Faker::Name.last_name

    fill_in "Twitter", with: Faker::Name.first_name

    fill_in "Tell us a little bit about yourself", with: Faker::Lorem.paragraph

  end
end
