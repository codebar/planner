RSpec.feature 'Announcements', type: :feature do
  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter_with_groups) }

  before do
    member.add_role(:organiser, chapter)
    login_as_admin(member)
  end

  describe 'an authorised member' do
    describe 'can successfully create a new announcement' do
      scenario 'when they fill in all details' do
        visit new_admin_announcement_path
        fill_in 'Message', with: 'An announcement'
        click_on 'announcement[create]'

        expect(page).to have_content('Announcement successfully created')
        expect(page.current_path).to eq(admin_announcements_path)
      end
    end

    describe 'can not create an announcement' do
      scenario 'when they don\'t fill in any of the mandatory details' do
        visit new_admin_announcement_path
        click_on 'announcement[create]'

        expect(page).to have_content('Please make sure you fill in all mandatory fields')
      end
    end

    describe 'can successfully edit a new announcement' do
      scenario 'by updating the fields they want to change' do
        announcement = Fabricate(:announcement)
        visit edit_admin_announcement_path(announcement)
        fill_in 'Message', with: 'New event coming up soon! Stay tuned.'
        click_on 'announcement[update]'

        expect(page).to have_content('Announcement successfully updated')
        expect(page).to have_content('New event coming up soon! Stay tuned.')
        expect(page.current_path).to eq(admin_announcements_path)
      end
    end

    scenario 'can view all announcements' do
      announcement = Fabricate(:announcement)
      old_announcement = Fabricate(:announcement, expires_at: Time.zone.now - 1.week)

      visit admin_announcements_path

      expect(page).to have_content(announcement.message)
      expect(page).to have_content(old_announcement.message)
    end

    scenario 'can successfully send a new announcement to every group' do
      visit new_admin_announcement_path
      fill_in 'Message', with: 'An announcement to every group'
      check 'Send to all groups'
      click_on 'announcement[create]'

      expect(page).to have_content('An announcement to every group')
      expect(page).to have_content("Coaches #{chapter.name}")
      expect(page).to have_content("Students #{chapter.name}")
      expect(page.current_path).to eq(admin_announcements_path)
    end

    scenario 'can successfully send a new announcement to selected groups' do
      visit new_admin_announcement_path
      fill_in 'Message', with: 'An announcement to selected groups'
      select "Coaches #{chapter.name}", from: 'Select group'
      click_on 'announcement[create]'

      expect(page).to have_content('An announcement to selected groups')
      expect(page).to have_content("Coaches #{chapter.name}")
      expect(page).to_not have_content("Students #{chapter.name}")
      expect(page.current_path).to eq(admin_announcements_path)
    end
  end
end
