require 'spec_helper'

RSpec.describe 'Managing workshop working groups' do
  let(:organiser) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now) }

  before do
    organiser.add_role(:organiser, workshop.chapter)
    login(organiser)
  end

  it 'hides Pairings on virtual workshops' do
    virtual = Fabricate(:virtual_workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now)
    organiser.add_role(:organiser, virtual.chapter)
    Fabricate(:workshop_invitation, workshop: virtual, role: 'Student', attending: true, attended: true,
                                    checked_in_at: 5.minutes.ago, automated_rsvp: true)

    visit admin_workshop_path(virtual)

    expect(page).to have_text('Virtual Workshop')
    expect(page).to have_no_css('.working-groups-board')
  end

  it 'hides Pairings before the 30-minute check-in window when no groups exist' do
    future = Fabricate(:workshop, date_and_time: 2.hours.from_now, ends_at: 4.hours.from_now)
    organiser.add_role(:organiser, future.chapter)
    Fabricate(:workshop_invitation, workshop: future, role: 'Student', attending: true, automated_rsvp: true)

    visit admin_workshop_path(future)

    expect(page).to have_text('Students')
    expect(page).to have_no_css('.working-groups-board')
  end

  it 'orders solo waiting rows by check-in time while keeping the check-in list alphabetical' do
    zara = Fabricate(:member, name: 'Zara', surname: 'Alpha')
    alice = Fabricate(:member, name: 'Alice', surname: 'Beta')

    Fabricate(:workshop_invitation, workshop:, member: zara, role: 'Student', attending: true, attended: true,
                                    checked_in_at: 10.minutes.ago, automated_rsvp: true,
                                    tutorial: 'Ruby Lesson 2', note: 'Needs help with hashes')
    Fabricate(:workshop_invitation, workshop:, member: alice, role: 'Student', attending: true, attended: true,
                                    checked_in_at: 2.minutes.ago, automated_rsvp: true, tutorial: 'CSS Grid')

    visit admin_workshop_path(workshop)

    within('.working-groups-board') do
      waiting_names = all('.working-group--waiting .working-group-slot__name').map(&:text)
      expect(waiting_names.first).to include('Zara Alpha')
      expect(waiting_names.second).to include('Alice Beta')
      expect(page).to have_text('Ruby Lesson 2')
      expect(page).to have_text('Needs help with hashes')
      expect(page).to have_text('Drop a coach here')
    end

    student_list_names = all('.attendances .row.attendee .col-5 a').map(&:text)
    alice_index = student_list_names.index { |n| n.include?('Alice Beta') }
    zara_index = student_list_names.index { |n| n.include?('Zara Alpha') }
    expect(alice_index).to be < zara_index
  end

  it 'renders multi-student working groups and lets organisers unlink a member into a solo row' do
    inv_zara = Fabricate(:workshop_invitation, workshop:, member: Fabricate(:member, name: 'Zara', surname: 'Alpha'),
                                               role: 'Student', attending: true, attended: true,
                                               checked_in_at: 10.minutes.ago, automated_rsvp: true)
    inv_alice = Fabricate(:workshop_invitation, workshop:, member: Fabricate(:member, name: 'Alice', surname: 'Beta'),
                                                role: 'Student', attending: true, attended: true,
                                                checked_in_at: 2.minutes.ago, automated_rsvp: true)
    inv_coach = Fabricate(:workshop_invitation, workshop:, member: Fabricate(:member, name: 'Bob', surname: 'Coach'),
                                                role: 'Coach', attending: true, attended: true,
                                                checked_in_at: 1.minute.ago, automated_rsvp: true)
    service = WorkingGroups::Service.for(workshop)
    service.on_check_in(inv_coach)
    service.assign(entry_id: inv_alice.id, target_group_id: service.board.groups.first.id)

    visit admin_workshop_path(workshop)
    within('.working-group--paired') do
      expect(page).to have_text('Zara Alpha')
      expect(page).to have_text('Alice Beta')
      expect(page).to have_text('Bob Coach')
      find("button[aria-label^='Move Alice Beta']").click
    end

    expect(page).to have_text('1 group')
    expect(page).to have_text('1 unpaired')
    expect(inv_alice.reload.workshop_working_group).to be_nil
    expect(inv_zara.reload.workshop_working_group).to be_present
  end

  it 'shows the New badge for first-time attendees even after they check in' do
    newbie = Fabricate(:member, name: 'First', surname: 'Timer')
    returning_member = Fabricate(:member, name: 'Regular', surname: 'Attendee')
    past_workshop = Fabricate(:past_workshop)
    Fabricate(:workshop_invitation, workshop: past_workshop, member: returning_member,
                                    role: 'Student', attending: true, attended: true, automated_rsvp: true)

    newbie_inv = Fabricate(:workshop_invitation, workshop:, member: newbie, role: 'Student', attending: true,
                                                 attended: true, checked_in_at: 5.minutes.ago, automated_rsvp: true)
    returning_inv = Fabricate(:workshop_invitation, workshop:, member: returning_member, role: 'Student',
                                                    attending: true, attended: true,
                                                    checked_in_at: 2.minutes.ago, automated_rsvp: true)

    visit admin_workshop_path(workshop)

    within("#working-group-waiting-#{newbie_inv.id}") { expect(page).to have_text('New') }
    within("#working-group-waiting-#{returning_inv.id}") { expect(page).to have_no_text('New') }
  end

  it 'lets organisers pull any checked-in attendee into a group via the searchable picker', :js do
    group_id, inv_fatima = seed_picker_scenario(workshop)

    visit admin_workshop_path(workshop)
    within("#working-group-#{group_id}") do
      click_button 'Add someone to this group'
      fill_in 'Search checked-in attendees to add to this group', with: 'DOM events'
      expect(page).to have_text('Fatima Wait')
      expect(page).to have_text('Tutorial: JavaScript')
      find('.working-group-picker__option', text: 'Fatima Wait').click
    end

    within("#working-group-#{group_id}") do
      expect(page).to have_text('Fatima Wait', wait: 5)
      expect(page).to have_text('Amara One')
    end
    expect(inv_fatima.reload.workshop_working_group_id).to eq(group_id)
  end

  def seed_picker_scenario(target_workshop)
    service = WorkingGroups::Service.for(target_workshop)
    amara = create_picker_invite(target_workshop, role: 'Student', mins_ago: 10, name: 'Amara', surname: 'One', tutorial: 'CSS')
    ben = create_picker_invite(target_workshop, role: 'Coach', mins_ago: 9, name: 'Ben', surname: 'Coach', note: 'CSS & JS')
    fatima = create_picker_invite(target_workshop, role: 'Student', mins_ago: 5, name: 'Fatima', surname: 'Wait', tutorial: 'JavaScript', note: 'DOM events')
    [amara, ben, fatima].each { |inv| service.on_check_in(inv) }
    [service.board.groups.first.id, fatima]
  end

  def create_picker_invite(target_workshop, role:, mins_ago:, **attrs)
    member = Fabricate(:member, name: attrs.delete(:name), surname: attrs.delete(:surname))
    Fabricate(:workshop_invitation, workshop: target_workshop, member:, role:, attending: true, attended: true,
                                    checked_in_at: mins_ago.minutes.ago, automated_rsvp: true, **attrs)
  end
end
