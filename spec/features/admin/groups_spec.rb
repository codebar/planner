RSpec.feature 'admin groups', type: :feature do
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

  context '#show page' do
    let(:member) { Fabricate(:member) }
    let(:chapter) { Fabricate(:chapter, name: 'Brighton') }
    let(:group) { Fabricate(:group, chapter: chapter, name: 'Students') }

    before do
      login_as_admin(member)
    end

    scenario 'shows explanation for eligible members' do
      visit admin_group_path(group)

      expect(page).to have_content('What is "eligible"?')
      expect(page).to have_content(/Are not banned/i)
    end
  end
end
