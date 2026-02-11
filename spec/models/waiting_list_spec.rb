RSpec.describe WaitingList do
  let(:workshop) { Fabricate(:workshop) }

  describe 'scopes' do
    describe '#by_workshop' do
      it 'is empty when there are not invitations in the waiting list' do
        expect(described_class.by_workshop(workshop)).to eq([])
      end

      it 'is returns the waiting list entries when there are any' do
        invitations = Array.new(2) { Fabricate(:workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| described_class.add(invitation) }

        expect(described_class.by_workshop(workshop).map(&:invitation)).to match_array(invitations)
      end
    end

    describe '#next_spot' do
      it 'returns the next spot to be allocated' do
        invitation = Fabricate(:workshop_invitation, workshop: workshop)
        described_class.add(invitation)

        expect(described_class.next_spot(workshop, 'Student').invitation).to eq(invitation)
      end
    end
  end

  describe '#add' do
    it 'is adds an invitation to the waiting list' do
      invitation = Fabricate(:workshop_invitation, workshop: workshop)
      described_class.add(invitation)

      expect(described_class.by_workshop(workshop).map(&:invitation)).to eq([invitation])
    end

    it 'is idempotent - returns existing record when called twice' do
      invitation = Fabricate(:workshop_invitation, workshop: workshop)

      first_call = described_class.add(invitation)
      second_call = described_class.add(invitation)

      expect(first_call.id).to eq(second_call.id)
      expect(described_class.by_workshop(workshop).count).to eq(1)
    end

    it 'does not change auto_rsvp on subsequent calls' do
      invitation = Fabricate(:workshop_invitation, workshop: workshop)

      described_class.add(invitation, true)
      second_entry = described_class.add(invitation, false)

      expect(second_entry.reload.auto_rsvp).to be(true)
    end
  end

  describe '#coaches_for' do
    it 'returns waitlisted coaches for a specific workshop' do
      coach = Fabricate(:coach)

      invitation = Fabricate(:coach_workshop_invitation, workshop: workshop, member: coach)
      coach_invitation = described_class.add(invitation)

      expect(described_class.coaches_for(workshop)).to eq([coach_invitation])
    end

    it 'returns waitlisted students for a specific workshop' do
      student = Fabricate(:student)

      invitation = Fabricate(:student_workshop_invitation, workshop: workshop, member: student)
      student_invitation = described_class.add(invitation)

      expect(described_class.students_for(workshop)).to eq([student_invitation])
    end
  end
end
