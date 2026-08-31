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

        expect(page).to have_text('Announcement successfully created')
        expect(page).to have_current_path(admin_announcements_path, ignore_query: true)
      end
    end

    describe 'can not create an announcement' do
      scenario 'when they don\'t fill in any of the mandatory details' do
        visit new_admin_announcement_path
        click_on 'announcement[create]'

        expect(page).to have_text('Please make sure you fill in all mandatory fields')
      end
    end

    describe 'can successfully edit a new announcement' do
      scenario 'by updating the fields they want to change' do
        announcement = Fabricate(:announcement)
        visit edit_admin_announcement_path(announcement)
        fill_in 'Message', with: 'New event coming up soon! Stay tuned.'
        click_on 'announcement[update]'

        expect(page).to have_text('Announcement successfully updated')
        expect(page).to have_text('New event coming up soon! Stay tuned.')
        expect(page).to have_current_path(admin_announcements_path, ignore_query: true)
      end

      scenario 'by updating the expires at date' do
        announcement = Fabricate(:announcement)
        new_date = 2.weeks.from_now.to_date
        visit edit_admin_announcement_path(announcement)
        fill_in 'Expires at', with: new_date
        click_on 'announcement[update]'

        expect(page).to have_text('Announcement successfully updated')
        announcement.reload
        expect(announcement.expires_at.to_date).to eq(new_date)
      end
    end

    scenario 'can view all announcements' do
      travel_to(Time.current) do
        announcement = Fabricate(:announcement)
        old_announcement = Fabricate(:announcement, expires_at: 1.week.ago)

        visit admin_announcements_path

        expect(page).to have_text(announcement.message)
        expect(page).to have_text(old_announcement.message)
      end
    end

    scenario 'can successfully send a new announcement to every group' do
      visit new_admin_announcement_path
      fill_in 'Message', with: 'An announcement to every group'
      check 'Send to all groups'
      click_on 'announcement[create]'

      expect(page).to have_text('An announcement to every group')
      expect(page).to have_text("Coaches #{chapter.name}")
      expect(page).to have_text("Students #{chapter.name}")
      expect(page).to have_current_path(admin_announcements_path, ignore_query: true)
    end

    scenario 'can successfully send a new announcement to selected groups' do
      visit new_admin_announcement_path
      fill_in 'Message', with: 'An announcement to selected groups'
      select "Coaches #{chapter.name}", from: 'Select group'
      click_on 'announcement[create]'

      expect(page).to have_text('An announcement to selected groups')
      expect(page).to have_text("Coaches #{chapter.name}")
      expect(page).to have_no_text("Students #{chapter.name}")
      expect(page).to have_current_path(admin_announcements_path, ignore_query: true)
    end
  end
end
