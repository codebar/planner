RSpec.describe ThreeMonthEmailService, type: :service do
  describe "#send_chaser" do
    subject(:call) { described_class.send_chaser }

    let!(:eligible_member)      { Fabricate(:member) }
    let!(:emailed_member)       { Fabricate(:member) }
    let!(:old_invite_member)    { Fabricate(:member) }

    before do
      # Eligible: recent invite, no email delivery
      Fabricate(
        :workshop_invitation,
        member: eligible_member,
        created_at: 3.months.ago,
        attended: false
      )

      # Already emailed: recent invite, but has email delivery
      Fabricate(
        :workshop_invitation,
        member: emailed_member,
        created_at: 2.months.ago
      )
      Fabricate(
        :member_email_delivery,
        member: emailed_member
      )

      # Old invite: more than 3 months ago
      Fabricate(
        :workshop_invitation,
        member: old_invite_member,
        created_at: 4.months.ago
      )
    end

    it "enqueues chaser emails only for eligible members" do
      expect {
        call
      }.to have_enqueued_mail(MemberMailer, :chaser).once
    end
  end
end
