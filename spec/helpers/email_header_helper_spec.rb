RSpec.describe EmailHeaderHelper do
  subject do
    Class.new do
      include EmailHeaderHelper
      public :mail_args
    end.new
  end

  describe '#mail_args' do
    let(:member) { Struct.new(:id, :email).new(1, 'test@example.com') }

    it 'returns mail arguments for valid email' do
      result = subject.mail_args(member, 'Test Subject')
      expect(result[:to]).to eq('test@example.com')
      expect(result[:subject]).to eq('Test Subject')
    end

    it 'returns nil for nil email' do
      member = Struct.new(:id, :email).new(1, nil)
      result = subject.mail_args(member, 'Test Subject')
      expect(result).to be_nil
    end

    it 'returns nil for blank email' do
      member = Struct.new(:id, :email).new(1, '')
      result = subject.mail_args(member, 'Test Subject')
      expect(result).to be_nil
    end

    it 'returns nil for invalid email format' do
      member = Struct.new(:id, :email).new(1, 'invalid-email')
      result = subject.mail_args(member, 'Test Subject')
      expect(result).to be_nil
    end

    it 'returns nil for email missing @ symbol' do
      member = Struct.new(:id, :email).new(1, 'invalidexample.com')
      result = subject.mail_args(member, 'Test Subject')
      expect(result).to be_nil
    end

    it 'returns nil for email missing TLD' do
      member = Struct.new(:id, :email).new(1, 'invalid@example')
      result = subject.mail_args(member, 'Test Subject')
      expect(result).to be_nil
    end

    it 'returns mail arguments for valid email with plus addressing' do
      member = Struct.new(:id, :email).new(1, 'user+tag@example.com')
      result = subject.mail_args(member, 'Test Subject')
      expect(result[:to]).to eq('user+tag@example.com')
    end

    it 'includes from email when provided' do
      result = subject.mail_args(member, 'Test Subject', 'custom@codebar.io')
      expect(result[:from]).to eq('codebar.io <custom@codebar.io>')
    end

    it 'includes cc and bcc when provided' do
      result = subject.mail_args(member, 'Test Subject', 'from@codebar.io', 'cc@codebar.io', 'bcc@codebar.io')
      expect(result[:cc]).to eq('cc@codebar.io')
      expect(result[:bcc]).to eq('bcc@codebar.io')
    end
  end
end
