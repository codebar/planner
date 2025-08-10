require 'spec_helper'

RSpec.feature 'admin member search', type: :feature do
  scenario 'search returns single member to requesting service' do
    Fabricate(:member, :name => 'Romeo', :surname => 'Montague')
    Fabricate(:member, :name => 'Juliet', :surname => 'Capulet')
    member = Fabricate(:member)
    login_as_admin(member)
    visit admin_member_search_index_path(callback: results_admin_member_search_index_path)

    fill_in 'member_search_name', with: 'Julie'
    click_button 'Search'

    expect(page).to have_current_path(results_admin_member_search_index_path, ignore_query: true)

    expect(page).to have_content('Juliet Capulet')
  end


end