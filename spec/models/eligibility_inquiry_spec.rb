RSpec.describe EligibilityInquiry do
  describe '#create' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    it 'creates an eligibility inquiry to a member issued by an admin' do
      eligibility_inquiry = EligibilityInquiry.create(member: member, issued_by: admin)

      expect(eligibility_inquiry.issued_by).to eq(admin)
    end

    it 'sends an eligibility check email' do
      expect {
        described_class.create(member: member, issued_by: admin)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(member.email)
      expect(email.subject).to include('Eligibility')
    end
  end
end
