require 'spec_helper'

feature 'admin groups' do
  context '#creating a new group' do
    let(:member) { Fabricate(:member) }
    let!(:chapter) { Fabricate(:chapter, name: 'Brighton') }

    before do
      login_as_admin(member)
    end

    scenario 'an admin can create a new chapter' do
      visit new_admin_group_path

      select 'Students', from: 'group[name]'
      select 'Brighton', from: 'group[chapter_id]'
      click_on 'Create group'

      expect(page).to have_content('Group Students for chapter Brighton has been successfully created')
    end
  end
end
