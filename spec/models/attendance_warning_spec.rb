RSpec.describe AttendanceWarning do
  describe '#create' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    it 'creates an attendance warning to a member issued by an admin' do
      attendance_warning = described_class.create(member: member, issued_by: admin)

      expect(attendance_warning.issued_by).to eq(admin)
    end

    it 'sends an attendance warning email' do
      described_class.create(member: member, issued_by: admin)

      email = ActionMailer::Base.deliveries.find { |e| e.to.include?(member.email) && e.subject.include?('Attendance') }
      expect(email).not_to be_nil
    end

    describe '.scopes' do
      describe 'last_six_months' do
        it 'returns all attendance warnings issues in the last six months' do
          travel_to(Time.current) do
            Fabricate(:attendance_warning, member: member, created_at: 7.months.ago)
            warnings = Fabricate.times(2, :attendance_warning, member: member, created_at: 5.months.ago)

            expect(member.attendance_warnings.last_six_months).to match_array(warnings)
          end
        end
      end
    end
  end
end
