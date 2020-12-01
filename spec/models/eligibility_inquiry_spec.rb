require 'spec_helper'

RSpec.describe EligibilityInquiry, type: :model do
  describe '#create' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    it 'creates an eligibility inquiry to a member issued by an admin' do
      eligibility_inquiry = EligibilityInquiry.create(member: member, issued_by: admin)

      expect(eligibility_inquiry.issued_by).to eq(admin)
    end

    it 'sends an attendance warning email' do
      allow(MemberMailer).to receive(:eligibility_check).with(member, member.email).and_call_original

      described_class.create(member: member, issued_by: admin)

      expect(MemberMailer).to have_received(:eligibility_check).with(member, member.email)
    end
  end
end
