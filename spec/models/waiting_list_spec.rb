RSpec.describe WaitingList do
  let(:workshop) { Fabricate(:workshop) }

  context 'scopes' do
    context '#by_workshop' do
      it 'is empty when there are not invitations in the waiting list' do
        expect(WaitingList.by_workshop(workshop)).to eq([])
      end

      it 'is returns the waiting list entries when there are any' do
        invitations = 2.times.map { Fabricate(:workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }

        expect(WaitingList.by_workshop(workshop).map(&:invitation)).to match_array(invitations)
      end
    end

    context '#next_spot' do
      it 'returns the next spot to be allocated' do
        invitation = Fabricate(:workshop_invitation, workshop: workshop)
        WaitingList.add(invitation)

        expect(WaitingList.next_spot(workshop, 'Student').invitation).to eq(invitation)
      end
    end
  end

  context '#add' do
    it 'is adds an invitation to the waiting list' do
      invitation = Fabricate(:workshop_invitation, workshop: workshop)
      WaitingList.add(invitation)

      expect(WaitingList.by_workshop(workshop).map(&:invitation)).to eq([invitation])
    end
  end

  context '#coaches_for' do
    it 'returns waitlisted coaches for a specific workshop' do
      coach = Fabricate(:coach)

      invitation = Fabricate(:coach_workshop_invitation, workshop: workshop, member: coach)
      coach_invitation = WaitingList.add(invitation)

      expect(WaitingList.coaches_for(workshop)).to eq([coach_invitation])
    end

    it 'returns waitlisted students for a specific workshop' do
      student = Fabricate(:student)
      
      invitation = Fabricate(:student_workshop_invitation, workshop: workshop, member: student)
      student_invitation = WaitingList.add(invitation)

      expect(WaitingList.students_for(workshop)).to eq([student_invitation])
    end
  end
end
