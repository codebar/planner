require 'spec_helper'

RSpec.describe WorkingGroups::Board do
  let(:t0) { Time.zone.parse('2026-11-25 18:00:00 UTC') }

  def check_in(board, entry_id, role, offset_minutes)
    board.reduce(
      described_class::CheckIn.new(entry_id:, role:, checked_in_at: t0 + offset_minutes.minutes)
    )
  end

  describe 'CheckIn (FIFO by check-in time)' do
    it 'places unmatched attendees in waiting ordered by check-in time' do
      board = described_class.new
      board = check_in(board, 20, 'Student', 5)
      board = check_in(board, 10, 'Student', 1)

      expect(board.groups).to be_empty
      expect(board.waiting.map(&:entry_id)).to eq([10, 20])
    end

    it 'pairs an arriving coach with the earliest waiting student by check-in time' do
      board = described_class.new
      board = check_in(board, 20, 'Student', 5)
      board = check_in(board, 10, 'Student', 1)
      board = check_in(board, 30, 'Coach', 6)

      expect(board.groups.size).to eq(1)
      expect(board.groups.first.participants.map(&:entry_id)).to eq([10, 30])
      expect(board.waiting.map(&:entry_id)).to eq([20])
    end

    it 'is idempotent when checking in an already present participant' do
      board = check_in(described_class.new, 10, 'Student', 1)
      again = check_in(board, 10, 'Student', 2)

      expect(again).to eq(board)
    end
  end

  describe 'Assign (*:* working groups)' do
    let(:student_a) { WorkingGroups::Participant.new(entry_id: 1, role: 'Student', checked_in_at: t0 + 1.minute) }
    let(:coach_one) { WorkingGroups::Participant.new(entry_id: 2, role: 'Coach', checked_in_at: t0 + 2.minutes) }
    let(:student_b) { WorkingGroups::Participant.new(entry_id: 3, role: 'Student', checked_in_at: t0 + 3.minutes) }
    let(:coach_two) { WorkingGroups::Participant.new(entry_id: 4, role: 'Coach', checked_in_at: t0 + 4.minutes) }
    let(:student_c) { WorkingGroups::Participant.new(entry_id: 5, role: 'Student', checked_in_at: t0 + 5.minutes) }

    let(:board) do
      described_class.new(
        groups: [
          WorkingGroups::Group.new(id: 100, position: 1, participants: [student_a, coach_one]),
          WorkingGroups::Group.new(id: 200, position: 2, participants: [student_b, coach_two])
        ],
        waiting: [student_c]
      )
    end

    it 'supports adding a waiting student to an existing group (2 students + 1 coach)' do
      updated = board.reduce(described_class::Assign.new(entry_id: 5, target_group_id: 100, target_entry_id: nil))

      expect(updated.groups[0].participants.map(&:entry_id)).to eq([1, 2, 5])
      expect(updated.groups[1].participants.map(&:entry_id)).to eq([3, 4])
      expect(updated.waiting).to be_empty
    end

    it 'moves a participant from one group into another and moves their lone former partner to waiting' do
      updated = board.reduce(described_class::Assign.new(entry_id: 1, target_group_id: 200, target_entry_id: nil))

      expect(updated.groups.map(&:id)).to eq([200])
      expect(updated.groups.first.participants.map(&:entry_id)).to eq([3, 4, 1])
      expect(updated.waiting.map(&:entry_id)).to eq([2, 5])
    end

    it 'pairs two waiting solo attendees into a new working group' do
      waiting_coach = WorkingGroups::Participant.new(entry_id: 6, role: 'Coach', checked_in_at: t0 + 6.minutes)
      with_coach = board.with(waiting: [student_c, waiting_coach])

      updated = with_coach.reduce(described_class::Assign.new(entry_id: 5, target_group_id: nil, target_entry_id: 6))

      expect(updated.groups.size).to eq(3)
      expect(updated.groups.last.participants.map(&:entry_id)).to eq([6, 5])
      expect(updated.waiting).to be_empty
    end
  end

  describe 'Unassign and CheckOut (determinism without cascading reshuffles)' do
    let(:student_a) { WorkingGroups::Participant.new(entry_id: 1, role: 'Student', checked_in_at: t0 + 1.minute) }
    let(:coach_one) { WorkingGroups::Participant.new(entry_id: 2, role: 'Coach', checked_in_at: t0 + 2.minutes) }
    let(:student_b) { WorkingGroups::Participant.new(entry_id: 3, role: 'Student', checked_in_at: t0 + 3.minutes) }
    let(:coach_two) { WorkingGroups::Participant.new(entry_id: 4, role: 'Coach', checked_in_at: t0 + 4.minutes) }
    let(:student_c) { WorkingGroups::Participant.new(entry_id: 5, role: 'Student', checked_in_at: t0 + 5.minutes) }

    let(:board) do
      described_class.new(
        groups: [
          WorkingGroups::Group.new(id: 100, position: 1, participants: [student_a, coach_one]),
          WorkingGroups::Group.new(id: 200, position: 2, participants: [student_b, coach_two])
        ],
        waiting: []
      )
    end

    it 'dissolves only the target pair on Unassign and preserves original check-in order' do
      updated = board.reduce(described_class::Unassign.new(entry_id: 1))

      expect(updated.groups.map(&:id)).to eq([200])
      expect(updated.groups.first.participants.map(&:entry_id)).to eq([3, 4])
      expect(updated.waiting.map(&:entry_id)).to eq([1, 2])
    end

    it 'keeps remaining 2 members paired when unassigning 1 member from a 3-person group' do
      trio_board = described_class.new(
        groups: [WorkingGroups::Group.new(id: 100, position: 1, participants: [student_a, student_c, coach_one])],
        waiting: []
      )

      updated = trio_board.reduce(described_class::Unassign.new(entry_id: 5))

      expect(updated.groups.size).to eq(1)
      expect(updated.groups.first.participants.map(&:entry_id)).to eq([1, 2])
      expect(updated.waiting.map(&:entry_id)).to eq([5])
    end

    it 'removes the checked-out coach and returns only their partner to waiting without touching other groups' do
      updated = board.reduce(described_class::CheckOut.new(entry_id: 2))

      expect(updated.groups.map(&:id)).to eq([200])
      expect(updated.groups.first.participants.map(&:entry_id)).to eq([3, 4])
      expect(updated.waiting.map(&:entry_id)).to eq([1])
    end
  end
end
