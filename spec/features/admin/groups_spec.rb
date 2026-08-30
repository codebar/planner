RSpec.feature 'admin groups', type: :feature do
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
