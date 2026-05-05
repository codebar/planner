require 'rails_helper'

RSpec.describe 'Admin TomSelect Member Lookup', :js, type: :feature do
  let(:admin) { Fabricate(:member) }
  let!(:member_jane) { Fabricate(:member, name: 'Jane', surname: 'Doe', email: 'jane@example.com') }
  let!(:member_john) { Fabricate(:member, name: 'John', surname: 'Smith', email: 'john@test.com') }

  before do
    admin.add_role(:admin)
    login_as_admin(admin)
  end

  scenario 'searching for members with TomSelect' do
    visit admin_members_path

    expect(page).to have_css('.ts-wrapper', wait: 5)

    find('.ts-control').click
    find('.ts-control input').send_keys('Ja')
    sleep 0.5

    find('.ts-control input').send_keys('ne')

    expect(page).to have_css('.ts-dropdown .option', wait: 5)

    expect(page).to have_content('Jane Doe')
    expect(page).to have_content('jane@example.com')

    expect(page).not_to have_content('John Smith')
  end

  scenario 'selecting a member updates view profile link' do
    visit admin_members_path

    expect(page).to have_css('.ts-wrapper', wait: 5)

    find('.ts-control').click
    find('.ts-control input').send_keys('Jane Doe')

    expect(page).to have_css('.ts-dropdown .option', wait: 5)

    find('.ts-dropdown .option', text: 'Jane Doe').click

    expect(find('#view_profile')[:href]).to include(admin_member_path(member_jane))
  end
end
