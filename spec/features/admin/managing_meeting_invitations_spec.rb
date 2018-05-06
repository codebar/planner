require 'spec_helper'

feature 'Managing meeting invitations' do
  let(:admin) { Fabricate(:member) }
  let(:meeting) { Fabricate(:meeting) }

  before do
    login_as_admin(admin)
    admin.add_role(:organiser, Meeting)
  end

  describe 'creating a new meeting invitation' do
    scenario 'for a member that is not already attending' do
      Fabricate(:attending_meeting_invitation, meeting: meeting)
      member = Fabricate(:member)

      visit admin_meeting_path(meeting)
      select member.name
      click_on 'Add'

      expect(page).to have_content("#{member.full_name} has been successfully added and notified via email")
    end

    scenario 'for a member that is already attending' do
      meeting = Fabricate(:meeting)
      attending_member = Fabricate(:member)
      Fabricate(:attending_meeting_invitation, meeting: meeting)
      Fabricate(:attending_meeting_invitation, meeting: meeting, member: attending_member)

      visit admin_meeting_path(meeting)
      select attending_member.name
      click_on 'Add'

      expect(page).to have_content("#{attending_member.full_name} is already on the list!")
    end
  end

  scenario 'Updating the attendance of an invitation' do
    meeting = Fabricate(:meeting, date_and_time: 1.day.ago)
    member = Fabricate(:member)
    Fabricate(:attending_meeting_invitation, meeting: meeting)

    visit admin_meeting_path(meeting)

    find('.verify-attendance').click

    expect(page).to have_content('Updated attendance')
  end
end
