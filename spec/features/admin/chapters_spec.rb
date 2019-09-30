require 'spec_helper'

RSpec.feature 'Chapters', type: :feature do
  let(:member) { Fabricate(:member) }

  context 'Authorization smoke test' do
    scenario 'Non-admins should be redirected' do
      login(member)

      visit new_admin_chapter_path

      expect(page).to have_current_path('/')
      expect(page).to have_content "You can't be here"
    end
  end

  context '#index' do
    let!(:active_chapters) { Fabricate.times(3, :active_chapter) }
    let!(:inactive_chapters) { Fabricate.times(3, :inactive_chapter) }

    background { login_as_admin(member) }

    scenario "an admin can view all chapters and it's information" do
      visit admin_chapters_path

      assert_chapters_exist_on_page(active_chapters)
      assert_chapters_exist_on_page(inactive_chapters)
    end

    scenario 'an admin can filter and view only active chapters' do
      visit admin_chapters_path
      click_link 'View Active Chapters'

      assert_chapters_exist_on_page(active_chapters)
      assert_chapters_not_exist_on_page(inactive_chapters)
    end

    scenario 'an admin can filter and view only inactive chapters' do
      visit admin_chapters_path
      click_link 'View Inactive Chapters'

      assert_chapters_exist_on_page(inactive_chapters)
      assert_chapters_not_exist_on_page(active_chapters)
    end

    scenario 'an admin can filter and view all chapters' do
      visit admin_chapters_path
      click_link 'View All Chapters'

      assert_chapters_exist_on_page(inactive_chapters)
      assert_chapters_exist_on_page(active_chapters)
    end

    scenario 'an admin can toggle the status of the active chapter' do
      visit admin_chapters_path
      first_active_chapter = active_chapters.first

      within(all('.row', text: first_active_chapter.email)[0]) do
        click_link 'Toggle Active Status'
      end

      expect(page).to have_content(
        "Successfully toggled active status for #{first_active_chapter.name}"
      )
      expect(first_active_chapter.reload).not_to be_active
    end

    scenario 'an admin can toggle the status of the inactive chapter' do
      visit admin_chapters_path
      first_inactive_chapter = inactive_chapters.first

      within(all('.row', text: first_inactive_chapter.email)[0]) do
        click_link 'Toggle Active Status'
      end

      expect(page).to have_content(
        "Successfully toggled active status for #{first_inactive_chapter.name}"
      )
      expect(first_inactive_chapter.reload).to be_active
    end
  end

  context '#creating a new chapter' do
    before do
      login_as_admin(member)
    end

    scenario 'an admin can create a new chapter' do
      visit new_admin_chapter_path

      fill_in 'Name', with: 'codebar Brighton'
      fill_in 'Email', with: 'brighton@codebar.io'
      fill_in 'City', with: 'Brighton'

      click_on 'Create chapter'

      expect(page).to have_content('Chapter codebar Brighton has been successfully created')
    end
  end

  context '#editing a chapter' do
    let(:chapter) { Fabricate(:chapter) }

    context 'organiser editing their chapter' do
      before do
        login(chapter.organisers.first)
      end

      scenario 'an organiser can update a chapter they organise' do
        visit edit_admin_chapter_path(chapter)

        fill_in 'Name', with: 'codebar Brighton'
        fill_in 'Email', with: 'brighton@codebar.io'
        fill_in 'City', with: 'Brighton'
        fill_in 'Twitter', with: '@codebarBrighton'
        fill_in 'Description', with: 'Description for Brighton chapter'
        attach_file('Image', Rails.root + 'spec/support/chapter-image.png')

        click_on 'Update chapter'

        expect(page).to have_content('Chapter codebar Brighton has been successfully updated')
      end
    end

    context 'organiser editing a chapter they do not organise' do
      let(:chapter_organiser) { Fabricate(:chapter_organiser) }

      before do
        login(chapter_organiser)
      end

      scenario 'an organiser cannot update a chapter they do not organise' do
        visit edit_admin_chapter_path(chapter)

        expect(page).to have_current_path('/')
        expect(page).to have_content('You are not authorized to perform this action.')
      end
    end

    context 'admin editing a chapter they do not organise' do
      let(:member) { Fabricate(:member) }

      before do
        login_as_admin(member)
      end

      scenario 'an admin can update a chapter they do not organise' do
        visit edit_admin_chapter_path(chapter)

        fill_in 'Name', with: 'codebar Brighton'
        fill_in 'Email', with: 'brighton@codebar.io'
        fill_in 'City', with: 'Brighton'

        click_on 'Update chapter'

        expect(page).to have_content('Chapter codebar Brighton has been successfully updated')
      end
    end
  end

  context 'viewing #members emails' do
    let(:chapter) { Fabricate(:chapter_with_groups) }

    before do
      login_as_admin(member)
    end

    scenario 'an admin can view emails of all members in a chapter' do
      visit admin_chapter_members_path(chapter)

      members_emails = chapter.members.map(&:email)

      members_emails.each do |email|
        expect(page).to have_content(email)
      end
    end

    scenario 'admin can view emails of only students' do
      visit admin_chapter_members_path(chapter, type: 'students')

      students_emails = chapter.students.map(&:email)
      coach_email = chapter.coaches.first.email

      students_emails.each do |email|
        expect(page).to have_content(email)
      end

      expect(page).not_to have_content(coach_email)
    end
  end

  private

  def assert_chapters_exist_on_page(chapters)
    chapters.each do |chapter|
      expect(page).to have_content(chapter.name)
      expect(page).to have_content(chapter.city)
      expect(page).to have_content(chapter.slug)
      expect(page).to have_content(chapter.email)
      expect(page).to have_content(chapter.twitter)
    end
  end

  def assert_chapters_not_exist_on_page(chapters)
    chapters.each do |chapter|
      expect(page).not_to have_content(chapter.name)
      expect(page).not_to have_content(chapter.city)
      expect(page).not_to have_content(chapter.slug)
      expect(page).not_to have_content(chapter.email)
      expect(page).not_to have_content(chapter.twitter)
    end
  end
end
