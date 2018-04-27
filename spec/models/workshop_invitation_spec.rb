require 'spec_helper'

describe WorkshopInvitation do
  context 'methods' do
    let(:invitation) { Fabricate(:student_workshop_invitation) }
    let!(:accepted_invitation) { 2.times { Fabricate(:workshop_invitation, attending: true) } }

    it_behaves_like InvitationConcerns
  end

  context 'scopes' do
    it '#attended' do
      4.times { Fabricate(:attended_workshop_invitation) }

      expect(WorkshopInvitation.attended.count).to eq(4)
    end

    it '#not_accepted' do
      4.times { Fabricate(:workshop_invitation, attending: nil) }
      4.times { Fabricate(:workshop_invitation, attending: false) }

      expect(WorkshopInvitation.not_accepted.count).to eq(8)
    end

    it '#to_coaches' do
      6.times { Fabricate(:coach_workshop_invitation) }

      expect(WorkshopInvitation.to_coaches.count).to eq(6)
    end

    it '#to_student' do
      4.times { Fabricate(:student_workshop_invitation) }

      expect(WorkshopInvitation.to_students.count).to eq(4)
    end
  end
end
