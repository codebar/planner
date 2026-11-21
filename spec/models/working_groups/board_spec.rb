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

  describe 'Assign (pair, replace, swap)' do
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

    it 'swaps same-role participants cleanly when dragging across two groups' do
      updated = board.reduce(described_class::Assign.new(entry_id: 1, target_group_id: 200, target_entry_id: nil))

      expect(updated.groups[0].participants.map(&:entry_id)).to eq([3, 2])
      expect(updated.groups[1].participants.map(&:entry_id)).to eq([1, 4])
      expect(updated.waiting.map(&:entry_id)).to eq([5])
    end

    it 'replaces the matching role and moves the displaced attendee to waiting when dragging from waiting' do
      updated = board.reduce(described_class::Assign.new(entry_id: 5, target_group_id: 200, target_entry_id: nil))

      expect(updated.groups[0].participants.map(&:entry_id)).to eq([1, 2])
      expect(updated.groups[1].participants.map(&:entry_id)).to eq([5, 4])
      expect(updated.waiting.map(&:entry_id)).to eq([3])
    end

    it 'pairs two waiting attendees of opposite roles' do
      waiting_coach = WorkingGroups::Participant.new(entry_id: 6, role: 'Coach', checked_in_at: t0 + 6.minutes)
      with_coach = described_class.new(groups: board.groups, waiting: [student_c, waiting_coach])

      updated = with_coach.reduce(described_class::Assign.new(entry_id: 5, target_group_id: nil, target_entry_id: 6))

      expect(updated.groups.size).to eq(3)
      expect(updated.groups.last.participants.map(&:entry_id)).to eq([6, 5])
      expect(updated.waiting).to be_empty
    end

    it 'ignores pairing two waiting attendees of the same role' do
      waiting_student = WorkingGroups::Participant.new(entry_id: 7, role: 'Student', checked_in_at: t0 + 7.minutes)
      with_two_students = described_class.new(groups: board.groups, waiting: [student_c, waiting_student])

      updated = with_two_students.reduce(
        described_class::Assign.new(entry_id: 5, target_group_id: nil, target_entry_id: 7)
      )

      expect(updated).to eq(with_two_students)
    end
  end

  describe 'Unassign and CheckOut (determinism without cascading reshuffles)' do
    let(:student_a) { WorkingGroups::Participant.new(entry_id: 1, role: 'Student', checked_in_at: t0 + 1.minute) }
    let(:coach_one) { WorkingGroups::Participant.new(entry_id: 2, role: 'Coach', checked_in_at: t0 + 2.minutes) }
    let(:student_b) { WorkingGroups::Participant.new(entry_id: 3, role: 'Student', checked_in_at: t0 + 3.minutes) }
    let(:coach_two) { WorkingGroups::Participant.new(entry_id: 4, role: 'Coach', checked_in_at: t0 + 4.minutes) }

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

    it 'removes the checked-out coach and returns only their partner to waiting without touching other groups' do
      updated = board.reduce(described_class::CheckOut.new(entry_id: 2))

      expect(updated.groups.map(&:id)).to eq([200])
      expect(updated.groups.first.participants.map(&:entry_id)).to eq([3, 4])
      expect(updated.waiting.map(&:entry_id)).to eq([1])
    end
  end
end
