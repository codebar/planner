require 'spec_helper'

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
      fill_in 'Local time', with: '11:30'
      fill_in 'Ends at', with: '12:00'
      select venue.name
      click_on 'Update'

      expect(page).to have_content('Meeting successfully created')
      expect(page.current_path)
        .to eq(admin_meeting_path("#{I18n.l(today, format: :year_month).downcase}-august-meeting-1"))
      expect(page).to have_content 'Invite'
    end

    scenario 'renders an error when no chapter has been selected' do
      visit new_admin_meeting_path

      click_on 'Update'

      expect(page).to have_content('Venue can\'t be blank')
    end
  end

  context 'updating an existing meeting' do
    let(:meeting) { Fabricate(:meeting, name: 'August Meeting') }

    scenario 'renders an error when no chapter has been selected' do
      Fabricate(:meeting, name: 'August Meeting')
      visit edit_admin_meeting_path(meeting)
      fill_in 'Slug', with: "#{I18n.l(meeting.date_and_time, format: :year_month).downcase}-august-meeting-1"

      click_on 'Update'

      expect(page).to have_content('Slug has already been taken')
    end

    scenario 'successfully' do
      permissions = Fabricate(:permission, resource: meeting, name: 'organiser')

      visit edit_admin_meeting_path(meeting)
      fill_in 'Name', with: "March Meeting"
      unselect permissions.members.first.full_name

      click_on 'Update'

      expect(page).to have_content('You have successfully updated the details of this meeting')
      expect(page).to have_css(%(span[title="#{permissions.members.last.full_name}"]))
      expect(page).to_not have_css(%(span[title="#{permissions.members.first.full_name}"]))
    end
  end

  context 'retrieving the attendee emails' do
    let(:meeting) { Fabricate(:meeting) }

    scenario 'when format: :text' do
      invitations = Fabricate.times(4, :attending_meeting_invitation, meeting: meeting)
      visit attendees_emails_admin_meeting_path(meeting, format: :text)

      invitations.each do |invitation|
        expect(page).to have_content(invitation.member.email)
      end
    end

    scenario 'when no format is used then it redirects to the meeting page' do
      visit attendees_emails_admin_meeting_path(meeting)

      expect(page.current_path).to eq(admin_meeting_path(meeting))
    end
  end

  context 'sending invitations' do
    scenario 'sends the invitations' do
      chapter = Fabricate(:chapter_with_groups)
      meeting = Fabricate(:meeting, chapters: [chapter])

      visit invite_admin_meeting_path(meeting)
      expect(page).to have_content("Invitations are being sent out")
    end

    scenario 'does not send the invitations to banned members' do
      chapter = Fabricate(:chapter_with_groups)
      meeting = Fabricate(:meeting, chapters: [chapter])
      chapter.members[1..2].each do |member|
        Fabricate(:ban, member: member)
      end
      permanent_ban = Fabricate.build(:ban, member: chapter.members[3], permanent: true, expires_at: nil)
      permanent_ban.save(validate: false)
      Fabricate(:ban, member: chapter.members[4], expires_at: Time.zone.today + 2.months)
      expired_ban = Fabricate.build(:ban, member: chapter.members[5], expires_at: Time.zone.today - 1.month)
      expired_ban.save(validate: false)

      expect do
        visit invite_admin_meeting_path(meeting)
      end.to change { ActionMailer::Base.deliveries.count }.by(chapter.members.count - 4)
    end
  end
end
