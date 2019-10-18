require 'spec_helper'

RSpec.describe CourseInvitation, type: :model  do
  let(:invitation) { Fabricate(:course_invitation) }
  let!(:accepted_invitation) { 2.times { Fabricate(:course_invitation, attending: true) } }

  it_behaves_like InvitationConcerns

  context '#role' do
    it 'sets the role to Student' do
      expect(invitation.role).to eq('Student')
    end
  end

  context '#parent' do
    it 'returns the parent course of the invitation' do
      expect(invitation.parent).to eq(invitation.course)
    end
  end
end
