require 'rails_helper'

RSpec.describe 'Admin TomSelect Member Lookup', :js, type: :feature do
  let(:admin) { Fabricate(:member) }
  let!(:member_jane) { Fabricate(:member, name: 'Jane', surname: 'Doe', email: 'jane@example.com') }

  before do
    Fabricate(:member, name: 'John', surname: 'Smith', email: 'john@test.com')
    admin.add_role(:admin)
    login_as_admin(admin)
  end

  scenario 'searching for members with TomSelect' do
    visit admin_members_path

    expect(page).to have_css('.ts-wrapper', wait: 15)

    find('.ts-control').click
    # Type in chunks to match shouldLoad (requires >= 3 chars).
    find('.ts-control input').send_keys('Ja')
    find('.ts-control input').send_keys('ne')

    expect(page).to have_css('.ts-dropdown .option', wait: 15)

    expect(page).to have_text('Jane Doe')
    expect(page).to have_text('jane@example.com')

    expect(page).to have_no_text('John Smith')
  end

  scenario 'selecting a member updates view profile link' do
    visit admin_members_path

    expect(page).to have_css('.ts-wrapper', wait: 15)

    find('.ts-control').click
    find('.ts-control input').send_keys('Jane Doe')

    expect(page).to have_css('.ts-dropdown .option', wait: 15)

    find('.ts-dropdown .option', text: 'Jane Doe').click

    expect(find_by_id('view_profile')[:href]).to include(admin_member_path(member_jane))
  end
end
