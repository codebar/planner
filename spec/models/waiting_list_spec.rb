require 'rails_helper'

RSpec.describe WaitingList do
  let(:workshop) { Fabricate(:workshop) }

  describe 'scopes' do
    describe '#by_workshop' do
      it 'is empty when there are not invitations in the waiting list' do
        expect(described_class.by_workshop(workshop)).to eq([])
      end

      it 'is returns the waiting list entries when there are any' do
        invitations = Array.new(2) { Fabricate(:workshop_invitation, workshop:) }
        invitations.each { |invitation| described_class.add(invitation) }

        expect(described_class.by_workshop(workshop).map(&:invitation)).to match_array(invitations)
      end
    end

    describe '#next_spot' do
      it 'returns the next spot to be allocated' do
        invitation = Fabricate(:workshop_invitation, workshop:)
        described_class.add(invitation)

        expect(described_class.next_spot(workshop, 'Student').invitation).to eq(invitation)
      end

      it 'ignores an older entry for another role' do
        coach_invitation = Fabricate(:coach_workshop_invitation, workshop:, member: Fabricate(:coach))
        described_class.add(coach_invitation)

        expect(described_class.next_spot(workshop, 'Student')).to be_nil
        expect(coach_invitation.reload.attending).to be_nil
        expect(described_class.by_workshop(workshop).count).to eq(1)
      end
    end

    describe '#promote_next' do
      it 'confirms the next auto-RSVP invitation and removes its waitlist entry' do
        invitation = Fabricate(:workshop_invitation, workshop:)
        described_class.add(invitation)

        promoted = described_class.promote_next(workshop, 'Student')

        expect(promoted).to eq(invitation)
        expect(invitation.reload.attending).to be(true)
        expect(invitation.automated_rsvp).to be(true)
        expect(described_class.by_workshop(workshop)).to be_empty
      end

      it 'promotes the FIFO head - the entry with the earliest created_at' do
        later_invitation = Fabricate(:workshop_invitation, workshop:)
        earlier_invitation = Fabricate(:workshop_invitation, workshop:)
        described_class.add(later_invitation)
        described_class.add(earlier_invitation).update!(created_at: 1.hour.ago)

        promoted = described_class.promote_next(workshop, 'Student')

        expect(promoted).to eq(earlier_invitation)
        expect(earlier_invitation.reload.attending).to be(true)
        expect(later_invitation.reload.attending).to be_nil
        expect(described_class.by_workshop(workshop).map(&:invitation)).to eq([later_invitation])
      end

      it 'returns nil and promotes nothing for an empty waitlist' do
        expect(described_class.promote_next(workshop, 'Student')).to be_nil
      end

      it 'does not promote entries without auto_rsvp' do
        invitation = Fabricate(:workshop_invitation, workshop:)
        described_class.add(invitation)

        waiting = described_class.by_workshop(workshop).first
        waiting.update!(auto_rsvp: false)

        expect(described_class.promote_next(workshop, 'Student')).to be_nil
        expect(invitation.reload.attending).to be_nil
      end

      it 'ignores an older entry for another role' do
        coach_invitation = Fabricate(:coach_workshop_invitation, workshop:, member: Fabricate(:coach))
        described_class.add(coach_invitation)

        expect(described_class.promote_next(workshop, 'Student')).to be_nil
        expect(coach_invitation.reload.attending).to be_nil
        expect(described_class.by_workshop(workshop).count).to eq(1)
      end
    end
  end

  describe '#add' do
    it 'is adds an invitation to the waiting list' do
      invitation = Fabricate(:workshop_invitation, workshop:)
      described_class.add(invitation)

      expect(described_class.by_workshop(workshop).map(&:invitation)).to eq([invitation])
    end

    it 'is idempotent - returns existing record when called twice' do
      invitation = Fabricate(:workshop_invitation, workshop:)

      first_call = described_class.add(invitation)
      second_call = described_class.add(invitation)

      expect(first_call.id).to eq(second_call.id)
      expect(described_class.by_workshop(workshop).count).to eq(1)
    end

    it 'does not change auto_rsvp on subsequent calls' do
      invitation = Fabricate(:workshop_invitation, workshop:)

      described_class.add(invitation, true)
      second_entry = described_class.add(invitation, false)

      expect(second_entry.reload.auto_rsvp).to be(true)
    end
  end

  describe '#coaches_for' do
    it 'returns waitlisted coaches for a specific workshop' do
      coach = Fabricate(:coach)

      invitation = Fabricate(:coach_workshop_invitation, workshop:, member: coach)
      coach_invitation = described_class.add(invitation)

      expect(described_class.coaches_for(workshop)).to eq([coach_invitation])
    end

    it 'returns waitlisted students for a specific workshop' do
      student = Fabricate(:student)

      invitation = Fabricate(:student_workshop_invitation, workshop:, member: student)
      student_invitation = described_class.add(invitation)

      expect(described_class.students_for(workshop)).to eq([student_invitation])
    end
  end
end
