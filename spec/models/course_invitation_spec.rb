require 'spec_helper'

RSpec.describe CourseInvitation, type: :model do
  let(:invitation) { Fabricate(:course_invitation) }
  it_behaves_like InvitationConcerns, :course_invitation, :course

  context 'defaults' do
    it { is_expected.to have_attributes(attending: nil) }
    it { is_expected.to have_attributes(attended: nil) }
  end

  context 'validates' do
    it { is_expected.to validate_presence_of(:course) }
    it { is_expected.to validate_presence_of(:member) }
  end

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
