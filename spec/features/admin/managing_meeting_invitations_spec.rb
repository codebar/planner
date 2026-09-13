require 'rails_helper'

RSpec.feature 'Managing meeting invitations' do
  let(:admin) { Fabricate(:member) }
  let(:meeting) { Fabricate(:meeting) }

  before do
    login_as_admin(admin)
    admin.add_role(:organiser, Meeting)
  end

  describe 'creating a new meeting invitation' do
    scenario 'for a member that is not already attending', :js do
      Fabricate(:attending_meeting_invitation, meeting:)
      member = Fabricate(:member)

      visit admin_meeting_path(meeting)

      select_from_tom_select(member.full_name, from: 'meeting_invitations_member')
      click_on 'Add'

      expect(page).to have_text("#{member.full_name} has been successfully added and notified via email")
    end

    scenario 'for a member that is already attending', :js do
      meeting = Fabricate(:meeting)
      attending_member = Fabricate(:member)
      Fabricate(:attending_meeting_invitation, meeting:)
      Fabricate(:attending_meeting_invitation, meeting:, member: attending_member)

      visit admin_meeting_path(meeting)

      select_from_tom_select(attending_member.full_name, from: 'meeting_invitations_member')
      click_on 'Add'

      expect(page).to have_text("#{attending_member.full_name} is already on the list!")
    end

    scenario 'selects a member when the first search request fails', :js do
      member = Fabricate(:member)
      Fabricate(:attending_meeting_invitation, meeting:)

      visit admin_meeting_path(meeting)

      # TomSelect caches search results per query, so one failed fetch poisons
      # that query permanently. Abort the first search request to simulate the
      # CI flake, then verify the helper recovers by searching again.
      aborted_first_search = false
      search_handler = proc do |route, _request|
        if aborted_first_search
          route.continue
        else
          aborted_first_search = true
          route.abort
        end
      end
      page.driver.with_playwright_page do |pw_page|
        pw_page.route('**/admin/members/search*', search_handler)
      end

      select_from_tom_select(member.full_name, from: 'meeting_invitations_member')
      click_on 'Add'

      expect(page).to have_text("#{member.full_name} has been successfully added and notified via email")
    end
  end

  scenario 'Updating the attendance of an invitation' do
    meeting = Fabricate(:meeting, date_and_time: 1.day.ago)
    Fabricate(:attending_meeting_invitation, meeting:)

    visit admin_meeting_path(meeting)
    find('.verify-attendance').click

    expect(page).to have_text('Updated attendance')
  end
end
