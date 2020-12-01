require 'spec_helper'

RSpec.describe AttendanceWarning, type: :model do
  describe '#create' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    it 'creates an attendance warning to a member issued by an admin' do
      attendance_warning = described_class.create(member: member, issued_by: admin)

      expect(attendance_warning.issued_by).to eq(admin)
    end

    it 'sends an attendance warning email' do
      allow(MemberMailer).to receive(:attendance_warning).with(member, member.email).and_call_original

      described_class.create(member: member, issued_by: admin)

      expect(MemberMailer).to have_received(:attendance_warning).with(member, member.email)
    end

    describe '.scopes' do
      describe 'last_six_months' do
        it 'returns all attendance warnings issues in the last six months' do
          Fabricate(:attendance_warning, member: member, created_at: 7.months.ago)
          warnings = Fabricate.times(2, :attendance_warning, member: member, created_at: 5.months.ago)

          expect(member.attendance_warnings.last_six_months).to contain_exactly(*warnings)
        end
      end
    end
  end
end
