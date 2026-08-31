RSpec.feature 'Chapters', type: :feature do
  let(:member) { Fabricate(:member) }

  context 'with authorization smoke test' do
    scenario 'Non-admins should be redirected' do
      login(member)

      visit new_admin_chapter_path

      expect(page).to have_current_path('/')
      expect(page).to have_text "You can't be here"
    end
  end

  describe '#creating a new chapter' do
    before do
      login_as_admin(member)
    end

    scenario 'an admin can create a new chapter' do
      visit new_admin_chapter_path

      fill_in 'Name', with: 'codebar Brighton'
      fill_in 'Email', with: 'brighton@codebar.io'
      fill_in 'City', with: 'Brighton'

      click_on 'Create chapter'

      expect(page).to have_text('Chapter codebar Brighton has been successfully created')

      chapter = Chapter.find_by(name: 'codebar Brighton')
      expect(chapter.groups.pluck(:name)).to match_array(%w[Students Coaches])
    end

    scenario 'an admin submitting an invalid form sees validation errors and no chapter is created' do
      visit new_admin_chapter_path

      fill_in 'Name', with: ''
      fill_in 'Email', with: ''
      fill_in 'City', with: 'Brighton'

      click_on 'Create chapter'

      expect(page).to have_text("Name can't be blank")
      expect(page).to have_text("Email can't be blank")
      expect(Chapter.count).to eq(0)
    end
  end

  describe '#editing a chapter' do
    let(:chapter) { Fabricate(:chapter_with_organiser) }

    context 'when an organiser editing their chapter' do
      before do
        login(chapter.organisers.first)
      end

      scenario 'an organiser can update a chapter they organise' do
        visit edit_admin_chapter_path(chapter)

        fill_in 'Name', with: 'codebar Brighton'
        fill_in 'Email', with: 'brighton@codebar.io'
        fill_in 'City', with: 'Brighton'
        fill_in 'Description', with: 'Description for Brighton chapter'
        attach_file('Image', Rails.root.join('spec/support/chapter-image.png'))

        click_on 'Update chapter'

        expect(page).to have_text('Chapter codebar Brighton has been successfully updated')
      end
    end

    context 'when an organiser editing a chapter they do not organise' do
      let(:chapter_organiser) { Fabricate(:chapter_organiser) }

      before do
        login(chapter_organiser)
      end

      scenario 'an organiser cannot update a chapter they do not organise' do
        visit edit_admin_chapter_path(chapter)

        expect(page).to have_current_path('/')
        expect(page).to have_text('You are not authorized to perform this action.')
      end
    end

    context 'when an admin is editing a chapter they do not organise' do
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

        expect(page).to have_text('Chapter codebar Brighton has been successfully updated')
      end
    end
  end

  context 'when viewing #members emails' do
    let(:chapter) { Fabricate(:chapter_with_groups) }

    before do
      login_as_admin(member)
    end

    scenario 'an admin can view emails of all members in a chapter' do
      visit admin_chapter_members_path(chapter)

      members_emails = chapter.members.map(&:email)

      members_emails.each do |email|
        expect(page).to have_text(email)
      end
    end

    scenario 'admin can view emails of only students' do
      visit admin_chapter_members_path(chapter, type: 'students')

      students_emails = chapter.students.map(&:email)
      coach_email = chapter.coaches.first.email

      students_emails.each do |email|
        expect(page).to have_text(email)
      end

      expect(page).to have_no_text(coach_email)
    end
  end

  context 'when viewing the how you found us card' do
    let(:chapter) { Fabricate(:chapter) }
    let(:group) { Fabricate(:group, chapter: chapter) }

    before do
      login_as_admin(member)
    end

    scenario 'shows the card when there are responses' do
      member_with_response = Fabricate(:member, how_you_found_us: :from_a_friend)
      Fabricate(:subscription, member: member_with_response, group: group)

      visit admin_chapter_path(chapter)

      expect(page).to have_text('How members found this chapter')
      expect(page).to have_text('Based on 1 response')
    end

    scenario 'does not show the card when there are no responses' do
      visit admin_chapter_path(chapter)

      expect(page).to have_css('body')
      expect(page).to have_no_text('How members found this chapter')
    end
  end

  context 'when eligible members tooltip' do
    let(:chapter) { Fabricate(:chapter) }

    before do
      login_as_admin(member)
    end

    scenario 'shows explanation for eligible members' do
      visit admin_chapter_path(chapter)

      expect(page).to have_text('What is "eligible"?')
      expect(page).to have_text(/Are not banned/i)
    end
  end
end
