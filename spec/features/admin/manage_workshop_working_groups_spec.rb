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

    expect(page).to have_text('2 groups')
    expect(page).to have_text('1 waiting')
    expect(inv_alice.reload.workshop_working_group).to be_nil
    expect(inv_zara.reload.workshop_working_group).to be_present
  end
end
