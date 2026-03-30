RSpec.describe InvitationLog do
  describe 'associations' do
    it { is_expected.to belong_to(:loggable) }
    it { is_expected.to belong_to(:initiator).class_name('Member').optional }
    it { is_expected.to belong_to(:chapter).optional }
    it { is_expected.to have_many(:entries).class_name('InvitationLogEntry').dependent(:destroy) }
  end

  describe 'enums' do
    it 'defines action enum with string values' do
      expect(InvitationLog.actions).to eq({ 'invite' => 'invite', 'reminder' => 'reminder', 'waiting_list_notification' => 'waiting_list_notification' })
    end

    it 'defines status enum with string values' do
      expect(InvitationLog.statuses).to eq({ 'running' => 'running', 'completed' => 'completed', 'failed' => 'failed' })
    end
  end

  describe 'before_create :set_expires_at' do
    it 'sets expires_at to 180 days from now on save' do
      log = Fabricate.build(:invitation_log)
      expect(log.expires_at).to be_nil
      log.save!
      expect(log.expires_at).to be_within(1.second).of(180.days.from_now)
    end
  end
end
