require 'spec_helper'

feature 'Managing events' do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter_with_groups) }
  let!(:event) { Fabricate(:event, confirmation_required: true) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, event)
  end

  scenario 'accessing an event' do
    visit admin_event_path(event)

    expect(page).to have_content(event.name)

    expect(page).to have_content 'Venue'
    expect(page).to have_content event.venue.name
  end

  scenario 'verifying an attendance' do
    invitation = Fabricate(:invitation, event: event, attending: true)
    visit admin_event_path(event)

    click_on 'Verify'

    expect(page).to have_content "You have verified #{invitation.member.full_name}'s spot at the event!"
    expect(invitation.reload.verified_by).to eq(member)
  end

  scenario 'cancelling an attendance' do
    invitation = Fabricate(:invitation, event: event, attending: true)
    visit admin_event_path(event)

    click_on 'Cancel'

    expect(page).to have_content "You have cancelled #{invitation.member.full_name}'s attendance."
    expect(invitation.reload.attending).to eq(false)
  end
end
