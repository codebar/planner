RSpec.describe EligibilityInquiry do
  describe '#create' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    it 'creates an eligibility inquiry to a member issued by an admin' do
      eligibility_inquiry = EligibilityInquiry.create(member: member, issued_by: admin)

      expect(eligibility_inquiry.issued_by).to eq(admin)
    end

  end
end
