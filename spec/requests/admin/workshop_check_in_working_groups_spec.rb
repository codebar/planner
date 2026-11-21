require 'spec_helper'

RSpec.describe 'Workshop check-in working group transitions' do
  let(:organiser) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now) }
  let(:student_invitation) do
    Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: true, attended: nil, automated_rsvp: true)
  end
  let(:coach_invitation) do
    Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: true, attended: nil, automated_rsvp: true)
  end

  before do
    organiser.add_role(:organiser, workshop.chapter)
    login(organiser)
  end

  it 'records checked_in_at and FIFO-pairs on admin check-in without sending emails' do
    expect do
      put admin_workshop_invitation_path(workshop, student_invitation, attended: true), xhr: true
      put admin_workshop_invitation_path(workshop, coach_invitation, attended: true), xhr: true
    end.not_to change(ActionMailer::Base.deliveries, :count)

    expect(student_invitation.reload.checked_in_at).to be_present
    expect(coach_invitation.reload.checked_in_at).to be_present

    board = WorkingGroups::Service.for(workshop).board
    expect(board.groups.size).to eq(1)
    expect(board.groups.first.student).to eq(student_invitation)
    expect(board.groups.first.coach).to eq(coach_invitation)
  end

  it 'clears checked_in_at and dissolves the group when admin unchecks an attendee' do
    put admin_workshop_invitation_path(workshop, student_invitation, attended: true), xhr: true
    put admin_workshop_invitation_path(workshop, coach_invitation, attended: true), xhr: true

    put admin_workshop_invitation_path(workshop, coach_invitation, attended: false), xhr: true

    expect(coach_invitation.reload.attended).to be_nil
    expect(coach_invitation.checked_in_at).to be_nil

    board = WorkingGroups::Service.for(workshop).board
    expect(board.groups).to be_empty
    expect(board.waiting).to eq([student_invitation])
  end

  it 'removes a cancelled attendee from their working group' do
    put admin_workshop_invitation_path(workshop, student_invitation, attended: true), xhr: true
    put admin_workshop_invitation_path(workshop, coach_invitation, attended: true), xhr: true

    put admin_workshop_invitation_path(workshop, student_invitation, attending: false), xhr: true

    board = WorkingGroups::Service.for(workshop).board
    expect(board.groups).to be_empty
    expect(board.waiting).to eq([coach_invitation])
  end

  it 'does not create working groups when checking in to a virtual workshop' do
    virtual = Fabricate(:virtual_workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now)
    organiser.add_role(:organiser, virtual.chapter)
    s_inv = Fabricate(:workshop_invitation, workshop: virtual, role: 'Student', attending: true, automated_rsvp: true)
    c_inv = Fabricate(:workshop_invitation, workshop: virtual, role: 'Coach', attending: true, automated_rsvp: true)

    put admin_workshop_invitation_path(virtual, s_inv, attended: true), xhr: true
    put admin_workshop_invitation_path(virtual, c_inv, attended: true), xhr: true

    expect(virtual.workshop_working_groups).to be_empty
  end

  it 'FIFO-pairs when an attendee checks in via QR self check-in' do
    put admin_workshop_invitation_path(workshop, student_invitation, attended: true), xhr: true

    login(coach_invitation.member)
    post check_in_w_path(code: workshop.check_in_code), params: { role: 'Coach' }

    expect(coach_invitation.reload.attended).to be true
    expect(coach_invitation.checked_in_at).to be_present

    board = WorkingGroups::Service.for(workshop).board
    expect(board.groups.size).to eq(1)
    expect(board.groups.first.student).to eq(student_invitation)
    expect(board.groups.first.coach).to eq(coach_invitation)
  end
end
