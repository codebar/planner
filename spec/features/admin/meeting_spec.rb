RSpec.feature 'Managing meetings', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:venue) { Fabricate(:sponsor) }
  let(:today) { Time.zone.now }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Meeting)
  end

  context 'creating a new meeting' do
    scenario 'successfully' do
      visit new_admin_meeting_path

      fill_in 'Name', with: 'August meeting'
      fill_in 'Local date', with: Date.current
      fill_in 'Starts at', with: '11:30'
      fill_in 'Ends at', with: '12:00'
      select venue.name
      click_on 'Save'

      expect(page).to have_content('Meeting successfully created')
      expect(page)
        .to have_current_path(admin_meeting_path("#{I18n.l(today, format: :year_month).downcase}-august-meeting-1"), ignore_query: true)
      expect(page).to have_content 'Invite'
    end

    scenario 'renders an error when no chapter has been selected' do
      visit new_admin_meeting_path

      click_on 'Save'

      expect(page).to have_content('Venue must be set')
    end
  end

  context 'updating an existing meeting' do
    let(:meeting) { Fabricate(:meeting, name: 'August Meeting') }

    scenario 'renders an error when no chapter has been selected' do
      Fabricate(:meeting, name: 'August Meeting')
      visit edit_admin_meeting_path(meeting)
      fill_in 'Slug', with: "#{I18n.l(meeting.date_and_time, format: :year_month).downcase}-august-meeting-1"

      click_on 'Save'

      expect(page).to have_content('Slug has already been taken')
    end

    scenario 'successfully', :js do
      permissions = Fabricate(:permission, resource: meeting, name: 'organiser')

      visit edit_admin_meeting_path(meeting)
      fill_in 'Name', with: 'March Meeting'
      remove_from_tom_select(permissions.members.first.full_name)

      click_on 'Save'

      expect(page).to have_content('You have successfully updated the details of this meeting')
      expect(page).to have_css(%(span[title="#{permissions.members.last.full_name}"]))
      expect(page).not_to have_css(%(span[title="#{permissions.members.first.full_name}"]))
    end

    scenario 'adding an organiser', :js do
      meeting = Fabricate(:meeting)
      new_organiser = Fabricate(:member)

      visit edit_admin_meeting_path(meeting)
      select_from_tom_select(new_organiser.full_name, from: 'meeting_organisers')

      click_on 'Save'

      expect(page).to have_css(%(span[title="#{new_organiser.full_name}"]))
    end
  end

  context 'retrieving the attendee emails' do
    let(:meeting) { Fabricate(:meeting) }

    scenario 'when format: :text' do
      invitations = Fabricate.times(2, :attending_meeting_invitation, meeting: meeting)
      visit attendees_emails_admin_meeting_path(meeting, format: :text)

      invitations.each do |invitation|
        expect(page).to have_content(invitation.member.email)
      end
    end

    scenario 'when no format is used then it redirects to the meeting page' do
      visit attendees_emails_admin_meeting_path(meeting)

      expect(page).to have_current_path(admin_meeting_path(meeting), ignore_query: true)
    end
  end

  context 'sending invitations' do
    scenario 'sends the invitations' do
      chapter = Fabricate(:chapter_with_groups)
      meeting = Fabricate(:meeting, chapters: [chapter])

      visit invite_admin_meeting_path(meeting)
      expect(page).to have_content('Invitations are being sent out')
    end

    scenario 'does not send the invitations to banned members' do
      # With 4 total members (2 students + 2 coaches), ban 2 active, 1 expired
      # Expected: 4 total - 2 active bans = 2 emails sent
      chapter = Fabricate(:chapter_with_groups)
      meeting = Fabricate(:meeting, chapters: [chapter])
      chapter.members[0..1].each do |member|
        Fabricate(:ban, member: member)
      end
      expired_ban = Fabricate.build(:ban, member: chapter.members[2], expires_at: Time.zone.today - 1.month)
      expired_ban.save(validate: false)

      expect do
        visit invite_admin_meeting_path(meeting)
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
