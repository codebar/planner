require 'rails_helper'

RSpec.describe Pairing::Board do
  let(:student_a) { described_class::Member.new(invitation_id: 1, role: 'Student') }
  let(:student_b) { described_class::Member.new(invitation_id: 2, role: 'Student') }
  let(:coach_a)   { described_class::Member.new(invitation_id: 10, role: 'Coach') }
  let(:coach_b)   { described_class::Member.new(invitation_id: 11, role: 'Coach') }

  describe 'CheckIn reducer' do
    it 'starts a new solo group when no opposite-role singleton is waiting' do
      board = described_class.new
      next_board = board.reduce(described_class::CheckIn.new(invitation_id: 1, role: 'Student'))

      expect(next_board.groups.map(&:members)).to eq([[student_a]])
      expect(next_board.groups.map(&:position)).to eq([1])
    end

    it 'greedily joins the earliest waiting opposite-role singleton (FIFO by position)' do
      g2 = described_class::Group.new(id: 20, position: 2, members: [student_b])
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      board = described_class.new([g2, g1])

      next_board = board.reduce(described_class::CheckIn.new(invitation_id: 10, role: 'Coach'))

      expect(next_board.groups.map(&:id)).to eq([10, 20])
      expect(next_board.groups.first.members).to eq([student_a, coach_a])
      expect(next_board.groups.last.members).to eq([student_b])
    end

    it 'is idempotent when the invitation is already on the board' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      board = described_class.new([g1])

      expect(board.reduce(described_class::CheckIn.new(invitation_id: 1, role: 'Student'))).to eq(board)
    end
  end

  describe 'Assign reducer' do
    it 'moves an invitation into another group and prunes emptied groups' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a, coach_a])
      g2 = described_class::Group.new(id: 20, position: 2, members: [student_b])
      board = described_class.new([g1, g2])

      next_board = board.reduce(described_class::Assign.new(invitation_id: 2, role: 'Student', target_group_id: 10))

      expect(next_board.groups.map(&:id)).to eq([10])
      expect(next_board.groups.first.members).to eq([student_a, coach_a, student_b])
    end

    it 'supports student-only and multi-coach groupings' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      g2 = described_class::Group.new(id: 20, position: 2, members: [student_b])
      board = described_class.new([g1, g2])

      next_board = board.reduce(described_class::Assign.new(invitation_id: 2, role: 'Student', target_group_id: 10))

      expect(next_board.groups.map(&:members)).to eq([[student_a, student_b]])
    end

    it 'is a safe no-op when dropping a member onto their own solo group' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      board = described_class.new([g1])

      expect(board.reduce(described_class::Assign.new(invitation_id: 1, role: 'Student', target_group_id: 10))).to eq(board)
    end
  end

  describe 'PullOut reducer' do
    it 'moves a member out of a multi-person group into a fresh solo group at the end' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a, coach_a])
      board = described_class.new([g1])

      next_board = board.reduce(described_class::PullOut.new(invitation_id: 1, role: 'Student'))

      expect(next_board.groups.size).to eq(2)
      expect(next_board.groups.first.members).to eq([coach_a])
      expect(next_board.groups.last.members).to eq([student_a])
      expect(next_board.groups.last.position).to eq(2)
    end

    it 'is a no-op when the member is already solo' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      g2 = described_class::Group.new(id: 20, position: 2, members: [coach_b])
      board = described_class.new([g1, g2])

      expect(board.reduce(described_class::PullOut.new(invitation_id: 1, role: 'Student'))).to eq(board)
    end
  end

  describe 'Remove reducer' do
    it 'removes the invitation and prunes any emptied group' do
      g1 = described_class::Group.new(id: 10, position: 1, members: [student_a])
      g2 = described_class::Group.new(id: 20, position: 2, members: [student_b, coach_a])
      board = described_class.new([g1, g2])

      after_first = board.reduce(described_class::Remove.new(invitation_id: 1))
      expect(after_first.groups.map(&:id)).to eq([20])

      after_second = after_first.reduce(described_class::Remove.new(invitation_id: 2))
      expect(after_second.groups.first.members).to eq([coach_a])
    end
  end
end
