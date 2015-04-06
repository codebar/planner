require 'spec_helper'

feature 'Managing workshop invitations' do
  let(:member) { Fabricate(:member) }
  let(:workshop) { Fabricate(:sessions) }
  let!(:invitations) { 10.times.map { Fabricate(:session_invitation, sessions: workshop, attending: nil) } }

  before do
    login_as_admin(member)
  end

  scenario "RSVP a user to a workshop" do
    member = invitations.first.member

    visit admin_workshop_path(workshop)
    select "#{member.full_name} (#{invitations.first.role})"
    click_on "RSVP"

    expect(page).to have_content("You have RSVPed #{member.full_name} to the workshop")
  end
end
