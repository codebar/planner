require 'rails_helper'

RSpec.describe Pairing do
  let(:event) { Fabricate(:event, confirmation_required: true) }
  let(:student_one) { Fabricate(:invitation, event:, attending: true, verified: false) }
  let(:student_two) { Fabricate(:invitation, event:, attending: true, verified: false) }
  let(:coach_one)   { Fabricate(:coach_invitation, event:, attending: true, verified: false) }
  let(:coach_two)   { Fabricate(:coach_invitation, event:, attending: true, verified: false) }

  describe 'automatic pairing on invitation state changes' do
    it 'auto-pairs checked-in students and coaches in FIFO order' do
      student_one.update!(verified: true)
      student_two.update!(verified: true)

      expect(event.pairings.ordered.count).to eq(2)
      expect(event.pairings.ordered.first).not_to be_mixed

      coach_one.update!(verified: true)

      first, second = event.pairings.with_members
      expect(first.invitations).to contain_exactly(student_one, coach_one)
      expect(first).to be_mixed
      expect(second.invitations).to contain_exactly(student_two)
      expect(second).not_to be_mixed
    end

    it 'removes a member from their pairing when attendance is cancelled' do
      student_one.update!(verified: true)
      coach_one.update!(verified: true)

      student_one.update!(attending: false)

      expect(event.pairings.count).to eq(1)
      expect(event.pairings.first.invitations).to contain_exactly(coach_one)

      coach_one.update!(attending: false)

      expect(event.pairings.count).to eq(0)
    end
  end

  describe '.add!' do
    it 'moves a member into another pairing to form a multi-student group' do
      student_one.update!(verified: true)
      coach_one.update!(verified: true)
      student_two.update!(verified: true)

      target = event.pairings.ordered.first
      described_class.add!(student_two, target)

      expect(event.pairings.count).to eq(1)
      expect(target.reload.invitations).to contain_exactly(student_one, student_two, coach_one)
    end

    it 'returns students and coaches sorted alphabetically by member name' do
      zara = Fabricate(:invitation, event:, member: Fabricate(:member, name: 'Zara', surname: 'Zulu'),
                                    attending: true, verified: true)
      amara = Fabricate(:invitation, event:, member: Fabricate(:member, name: 'Amara', surname: 'Alpha'),
                                     attending: true, verified: true)
      target = event.pairings.ordered.first
      described_class.add!(amara, target)

      expect(target.reload.student_invitations.map { |i| i.member.name }).to eq(%w[Amara Zara])
      expect(zara).to be_verified
    end

    it 'safely no-ops when dropping a solo member onto their own pairing' do
      student_one.update!(verified: true)
      solo = event.pairings.first

      expect { described_class.add!(student_one, solo) }.not_to raise_error
      expect(event.pairings.count).to eq(1)
      expect(solo.reload.invitations).to contain_exactly(student_one)
    end
  end

  describe '.pull_out!' do
    it 'splits a member out into a fresh solo pairing' do
      student_one.update!(verified: true)
      coach_one.update!(verified: true)

      described_class.pull_out!(student_one)

      pairings = event.pairings.with_members
      expect(pairings.size).to eq(2)
      expect(pairings.first.invitations).to contain_exactly(coach_one)
      expect(pairings.last.invitations).to contain_exactly(student_one)
    end

    it 'does not reorder an already-solo member' do
      student_one.update!(verified: true)
      student_two.update!(verified: true)
      original_ids = event.pairings.ordered.pluck(:id)

      described_class.pull_out!(student_one)

      expect(event.pairings.ordered.pluck(:id)).to eq(original_ids)
    end
  end

  describe '.sync!' do
    it 'backfills pairings for pre-existing verified invitations' do
      student_one.update_column(:verified, true)
      coach_one.update_column(:verified, true)

      expect(event.pairings.count).to eq(0)

      described_class.sync!(event)

      expect(event.pairings.count).to eq(1)
      expect(event.pairings.first.invitations).to contain_exactly(student_one, coach_one)
    end
  end

  describe 'cascading deletes' do
    it 'deletes pairings when the event is destroyed' do
      student_one.update!(verified: true)
      coach_two.update!(verified: true)

      expect { event.destroy! }.not_to raise_error
      expect(described_class.where(event_id: event.id)).to be_empty
    end
  end
end
