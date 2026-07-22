RSpec.feature 'Managing events', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:event) { Fabricate(:event, confirmation_required: true) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, event)
  end

  scenario 'accessing an event' do
    visit admin_event_path(event)

    expect(page).to have_text(event.name)

    expect(page).to have_text 'Venue'
    expect(page).to have_text event.venue.name
  end

  scenario 'adding all chapters to an event with one click', :js do
    Fabricate.times(2, :chapter)
    visit edit_admin_event_path(event)

    find_by_id('event_chapter_ids_chosen').click
    find('.add-all-chapters', text: 'Add to all').click
    expect(page).to have_no_css('#event_chapter_ids_chosen.chosen-with-drop')

    click_on 'Save'

    expect(page).to have_text('You have just updated the event')
    expect(event.reload.chapter_ids).to match_array(Chapter.ids)
  end

  scenario 'verifying an attendance' do
    invitation = Fabricate(:invitation, event: event, attending: true)
    visit admin_event_path(event)

    click_on 'Verify'

    expect(page).to have_text "You have verified #{invitation.member.full_name}'s spot at the event!"
    expect(invitation.reload.verified_by).to eq(member)
  end

  scenario 'cancelling an attendance' do
    invitation = Fabricate(:invitation, event: event, attending: true)
    visit admin_event_path(event)

    click_on 'Cancel'

    expect(page).to have_text "You have cancelled #{invitation.member.full_name}'s attendance."
    expect(invitation.reload.attending).to be(false)
  end

  scenario 'accessing a list of attendee emails' do
    student_invitation = Fabricate(:invitation, event: event, attending: true)
    coach_invitation = Fabricate(:coach_invitation, event: event, attending: true)
    visit admin_event_path(event)

    click_on 'Emails'

    expect(page).to have_text('COACHES')
    expect(page).to have_text(coach_invitation.member.email)
    expect(page).to have_text('STUDENTS')
    expect(page).to have_text(student_invitation.member.email)
  end
end
