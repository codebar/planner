require 'rails_helper'

RSpec.feature 'admin member search' do
  # Names and emails are pinned: the search matches name and email with ILIKE
  # '%Julie%', and Faker draws a name or email containing "julie" about 0.09%
  # of the time, which turns the single expected match into two and flakes the
  # redirect assertion.
  scenario 'search returns single member to requesting service' do
    Fabricate(:member, name: 'Romeo', surname: 'Montague', email: 'romeo.montague@example.com')
    Fabricate(:member, name: 'Juliet', surname: 'Capulet', email: 'juliet.capulet@example.com')
    member = Fabricate(:member, name: 'Anne', surname: 'Archer', email: 'anne.archer@example.com')
    login_as_admin(member)
    visit admin_member_search_index_path(callback_url: results_admin_member_search_index_path)

    fill_in 'member_search_name', with: 'Julie'
    click_button 'Search'

    expect(page).to have_current_path(results_admin_member_search_index_path, ignore_query: true)

    expect(page).to have_text('Juliet Capulet')
  end
end
