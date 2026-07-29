RSpec.feature 'admin groups', type: :feature do
  describe '#creating a new group' do
    let(:member) { Fabricate(:member) }

    before do
      Fabricate(:chapter, name: 'Brighton')
      login_as_admin(member)
    end

    scenario 'an admin can create a new chapter' do
      visit new_admin_group_path

      select 'Students', from: 'group[name]'
      select 'Brighton', from: 'group[chapter_id]'
      click_on 'Create group'

      expect(page).to have_text('Group Students for chapter Brighton has been successfully created')
    end
  end

  describe '#show page' do
    let(:member) { Fabricate(:member) }
    let(:chapter) { Fabricate(:chapter, name: 'Brighton') }
    let(:group) { Fabricate(:group, chapter: chapter, name: 'Students') }

    before do
      login_as_admin(member)
    end

    scenario 'shows explanation for eligible members' do
      visit admin_group_path(group)

      expect(page).to have_text('What is "eligible"?')
      expect(page).to have_text(/Are not banned/i)
    end
  end
end
