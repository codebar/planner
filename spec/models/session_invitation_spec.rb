require 'spec_helper'

describe SessionInvitation do
  context 'methods' do
    let(:invitation) { Fabricate(:student_session_invitation) }
    let!(:accepted_invitation) { 2.times { Fabricate(:session_invitation, attending: true) } }

    it_behaves_like InvitationConcerns
  end

  context 'scopes' do
    it '#attended' do
      4.times { Fabricate(:attended_session_invitation) }

      expect(SessionInvitation.attended.count).to eq(4)
    end

    it '#not_accepted' do
      4.times { Fabricate(:session_invitation, attending: nil) }
      4.times { Fabricate(:session_invitation, attending: false) }

      expect(SessionInvitation.not_accepted.count).to eq(8)
    end

    it '#to_coaches' do
      6.times { Fabricate(:coach_session_invitation) }

      expect(SessionInvitation.to_coaches.count).to eq(6)
    end

    it '#to_student' do
      4.times { Fabricate(:student_session_invitation) }

      expect(SessionInvitation.to_students.count).to eq(4)
    end
  end
end
