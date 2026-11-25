require 'spec_helper'

RSpec.describe WorkingGroups::Service do
  let(:workshop) { Fabricate(:workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now) }
  let(:service) { described_class.for(workshop) }

  def create_checked_in(role:, checked_in_at:, target_workshop: workshop)
    Fabricate(:workshop_invitation,
              workshop: target_workshop,
              role:,
              attending: true,
              attended: true,
              checked_in_at:,
              automated_rsvp: true)
  end

  describe '#visible?' do
    it 'is false for virtual workshops even inside the check-in window' do
      virtual = Fabricate(:virtual_workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now)
      expect(described_class.for(virtual).visible?).to be false
    end

    it 'is false more than 30 minutes before an in-person workshop with no saved groups' do
      future = Fabricate(:workshop, date_and_time: 45.minutes.from_now, ends_at: 3.hours.from_now)
      expect(described_class.for(future).visible?).to be false
    end

    it 'is true within 30 minutes of start for an in-person workshop' do
      expect(service.visible?).to be true
    end

    it 'is true for a past workshop with saved working groups' do
      past = Fabricate(:past_workshop)
      student = create_checked_in(role: 'Student', checked_in_at: 3.months.ago, target_workshop: past)
      coach = create_checked_in(role: 'Coach', checked_in_at: 3.months.ago, target_workshop: past)
      group = WorkshopWorkingGroup.create!(workshop: past, position: 1)
      WorkshopInvitationWorkingGroup.create!(workshop_working_group: group, workshop_invitation: student)
      WorkshopInvitationWorkingGroup.create!(workshop_working_group: group, workshop_invitation: coach)

      expect(described_class.for(past).visible?).to be true
    end
  end

  describe '#on_check_in and #board' do
    it 'performs zero database writes when reading #board' do
      create_checked_in(role: 'Student', checked_in_at: 5.minutes.ago)
      create_checked_in(role: 'Coach', checked_in_at: 4.minutes.ago)

      expect { service.board }.not_to change(WorkshopWorkingGroup, :count)
      expect(service.board.waiting.size).to eq(2)
    end

    it 'FIFO-pairs by check-in time rather than alphabetical name' do
      zara = Fabricate(:member, name: 'Zara', surname: 'First')
      alice = Fabricate(:member, name: 'Alice', surname: 'Second')
      coach_member = Fabricate(:member, name: 'Bob', surname: 'Coach')

      inv_zara = Fabricate(:workshop_invitation, workshop:, member: zara, role: 'Student',
                                                 attending: true, attended: true,
                                                 checked_in_at: 10.minutes.ago, automated_rsvp: true)
      inv_alice = Fabricate(:workshop_invitation, workshop:, member: alice, role: 'Student',
                                                  attending: true, attended: true,
                                                  checked_in_at: 5.minutes.ago, automated_rsvp: true)
      inv_coach = Fabricate(:workshop_invitation, workshop:, member: coach_member, role: 'Coach',
                                                  attending: true, attended: true,
                                                  checked_in_at: 1.minute.ago, automated_rsvp: true)

      service.on_check_in(inv_zara)
      service.on_check_in(inv_alice)
      service.on_check_in(inv_coach)

      board = service.board
      expect(board.groups.size).to eq(1)
      expect(board.groups.first.student).to eq(inv_zara)
      expect(board.groups.first.coach).to eq(inv_coach)
      expect(board.waiting).to eq([inv_alice])
    end

    it 'does not reshuffle existing pairs when an earlier coach checks out' do
      s1 = create_checked_in(role: 'Student', checked_in_at: 10.minutes.ago)
      c1 = create_checked_in(role: 'Coach', checked_in_at: 9.minutes.ago)
      s2 = create_checked_in(role: 'Student', checked_in_at: 8.minutes.ago)
      c2 = create_checked_in(role: 'Coach', checked_in_at: 7.minutes.ago)

      [s1, c1, s2, c2].each { |inv| service.on_check_in(inv) }

      c1.update!(attended: nil, checked_in_at: nil)
      service.on_check_out(c1)

      board = service.board
      expect(board.groups.size).to eq(1)
      expect(board.groups.first.student).to eq(s2)
      expect(board.groups.first.coach).to eq(c2)
      expect(board.waiting).to eq([s1])
    end

    it 'accepts a decorated WorkshopPresenter transparently' do
      decorated = WorkshopPresenter.decorate(workshop)
      expect(described_class.for(decorated).visible?).to be true
    end
  end

  describe '#assign and #unassign' do
    it 'supports 2:1 multi-student working groups and pulling a student back into solo waiting' do
      s1 = create_checked_in(role: 'Student', checked_in_at: 10.minutes.ago)
      c1 = create_checked_in(role: 'Coach', checked_in_at: 9.minutes.ago)
      s2 = create_checked_in(role: 'Student', checked_in_at: 8.minutes.ago)
      [s1, c1, s2].each { |inv| service.on_check_in(inv) }

      initial = service.board
      first_group_id = initial.groups.first.id

      grouped = service.assign(entry_id: s2.id, target_group_id: first_group_id)
      expect(grouped.groups.size).to eq(1)
      expect(grouped.groups.first.students).to contain_exactly(s1, s2)
      expect(grouped.groups.first.coaches).to eq([c1])
      expect(grouped.waiting).to be_empty

      unassigned = service.unassign(entry_id: s2.id)
      expect(unassigned.groups.size).to eq(1)
      expect(unassigned.groups.first.students).to eq([s1])
      expect(unassigned.waiting).to eq([s2])
    end

    it 'cleans up stale <2-member group links so remaining attendees can be re-paired without unique errors' do
      s1 = create_checked_in(role: 'Student', checked_in_at: 10.minutes.ago)
      c1 = create_checked_in(role: 'Coach', checked_in_at: 9.minutes.ago)
      c2 = create_checked_in(role: 'Coach', checked_in_at: 5.minutes.ago)
      service.on_check_in(s1)
      service.on_check_in(c1)

      # Simulate c1 dropping out without on_check_out running (e.g. concurrent uncheck or ban)
      c1.update!(attended: nil, checked_in_at: nil)

      expect { service.on_check_in(c2) }.not_to raise_error

      board = service.board
      expect(board.groups.size).to eq(1)
      expect(board.groups.first.students).to eq([s1])
      expect(board.groups.first.coaches).to eq([c2])
    end

    it 'sweeps stale links inside a retained 3-person group on the next write' do
      s1 = create_checked_in(role: 'Student', checked_in_at: 10.minutes.ago)
      s2 = create_checked_in(role: 'Student', checked_in_at: 9.minutes.ago)
      c1 = create_checked_in(role: 'Coach', checked_in_at: 8.minutes.ago)
      s3 = create_checked_in(role: 'Student', checked_in_at: 6.minutes.ago)
      c2 = create_checked_in(role: 'Coach', checked_in_at: 5.minutes.ago)
      service.on_check_in(s1)
      service.on_check_in(c1)
      service.assign(entry_id: s2.id, target_group_id: service.board.groups.first.id)

      # s2 drops out without on_check_out while Group 1 retains [s1, c1]; another write sweeps s2's stale link
      s2.update!(attended: nil, checked_in_at: nil)
      service.on_check_in(s3)
      service.on_check_in(c2)

      expect(WorkshopInvitationWorkingGroup.exists?(workshop_invitation_id: s2.id)).to be false
      expect(service.board.groups.size).to eq(2)
    end
  end
end
