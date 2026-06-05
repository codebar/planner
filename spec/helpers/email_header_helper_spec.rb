RSpec.describe EmailHeaderHelper, type: :helper do
  before do
    EmailHeaderHelper.module_eval { public :mail_to_member }
  end

  describe '#mail_to_member' do
    let(:member) { Struct.new(:id, :email).new(1, 'test@example.com') }

    it 'calls mail with correct arguments for valid email' do
      expect(helper).to receive(:mail).with(
        from: 'codebar.io <meetings@codebar.io>',
        to: 'test@example.com',
        cc: '',
        bcc: '',
        subject: 'Test Subject'
      )
      helper.mail_to_member(member, 'Test Subject')
    end

    it 'forwards the block to mail' do
      expect(helper).to receive(:mail) do |**kwargs, &block|
        expect(kwargs).to include(from: 'codebar.io <meetings@codebar.io>')
        expect(block).to be_a(Proc)
      end
      helper.mail_to_member(member, 'Test Subject') { |format| format.html }
    end

    it 'returns SkippedEmail for nil email' do
      member = Struct.new(:id, :email).new(1, nil)
      result = helper.mail_to_member(member, 'Test Subject')
      expect(result).to be_a(EmailHeaderHelper::SkippedEmail)
    end

    it 'returns SkippedEmail for blank email' do
      member = Struct.new(:id, :email).new(1, '')
      result = helper.mail_to_member(member, 'Test Subject')
      expect(result).to be_a(EmailHeaderHelper::SkippedEmail)
    end

    it 'returns SkippedEmail for invalid email format' do
      member = Struct.new(:id, :email).new(1, 'invalid-email')
      result = helper.mail_to_member(member, 'Test Subject')
      expect(result).to be_a(EmailHeaderHelper::SkippedEmail)
    end

    it 'returns SkippedEmail for email missing @ symbol' do
      member = Struct.new(:id, :email).new(1, 'invalidexample.com')
      result = helper.mail_to_member(member, 'Test Subject')
      expect(result).to be_a(EmailHeaderHelper::SkippedEmail)
    end

    it 'returns SkippedEmail for email missing TLD' do
      member = Struct.new(:id, :email).new(1, 'invalid@example')
      result = helper.mail_to_member(member, 'Test Subject')
      expect(result).to be_a(EmailHeaderHelper::SkippedEmail)
    end

    it 'logs the skip' do
      member = Struct.new(:id, :email).new(1, 'bad-email')
      expect(Rails.logger).to receive(:info).with(/Skipped email to member 1/)
      helper.mail_to_member(member, 'Test Subject')
    end

    it 'includes custom from email when provided' do
      expect(helper).to receive(:mail).with(hash_including(from: 'codebar.io <custom@codebar.io>'))
      helper.mail_to_member(member, 'Test Subject', 'custom@codebar.io')
    end

    it 'includes cc and bcc when provided' do
      expect(helper).to receive(:mail).with(
        hash_including(cc: 'cc@codebar.io', bcc: 'bcc@codebar.io')
      )
      helper.mail_to_member(member, 'Test Subject', 'from@codebar.io', 'cc@codebar.io', 'bcc@codebar.io')
    end
  end


end
