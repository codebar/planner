require 'rails_helper'

RSpec.describe ChapterContactConfirmation do
  let(:chapter) { Fabricate(:chapter) }
  let(:sender) { Fabricate(:member) }

  describe '.create_for!' do
    it 'stores a digest, unique recipient snapshot, and short expiry while returning the raw token' do
      confirmation = described_class.create_for!(
        chapter:, sender:, subject: 'Update', message: 'Hello', recipient_ids: [1, 2, 2]
      )

      expect(confirmation.token).to be_present
      expect(confirmation.token_digest).to eq(Digest::SHA256.hexdigest(confirmation.token))
      expect(confirmation.token_digest).not_to eq(confirmation.token)
      expect(confirmation.recipient_ids).to eq([1, 2])
      expect(confirmation.expires_at).to be_within(1.second).of(30.minutes.from_now)
    end
  end

  describe '.find_for' do
    let(:confirmation) do
      described_class.create_for!(
        chapter:, sender:, subject: 'Update', message: 'Hello', recipient_ids: [1]
      )
    end

    it 'requires the matching chapter, sender, and raw token' do
      expect(described_class.find_for(chapter:, sender:, token: confirmation.token)).to eq(confirmation)
      expect(described_class.find_for(chapter: Fabricate(:chapter), sender:, token: confirmation.token)).to be_nil
      expect(described_class.find_for(chapter:, sender: Fabricate(:member), token: confirmation.token)).to be_nil
      expect(described_class.find_for(chapter:, sender:, token: 'wrong-token')).to be_nil
    end

    it 'rejects blank and non-string tokens' do
      expect(described_class.find_for(chapter:, sender:, token: '')).to be_nil
      expect(described_class.find_for(chapter:, sender:, token: nil)).to be_nil
    end
  end

  describe '#usable_at?' do
    it 'expires at the exact expiry timestamp and becomes unusable after consumption' do
      confirmation = described_class.create_for!(
        chapter:, sender:, subject: 'Update', message: 'Hello', recipient_ids: [1]
      )

      expect(confirmation.usable_at?(confirmation.expires_at - 1.second)).to be(true)
      expect(confirmation.usable_at?(confirmation.expires_at)).to be(false)
      confirmation.update!(consumed_at: Time.current)
      expect(confirmation.usable_at?(Time.current)).to be(false)
    end
  end

  describe '#consume!' do
    it 'yields and consumes only once' do
      confirmation = described_class.create_for!(
        chapter:, sender:, subject: 'Update', message: 'Hello', recipient_ids: [1]
      )
      consumed = []

      expect(confirmation.consume! { consumed << true }).to be(true)
      expect(confirmation.consume! { consumed << true }).to be(false)
      expect(confirmation.reload.consumed_at).to be_present
      expect(consumed).to eq([true])
    end

    it 'rolls back consumption if the operation fails' do
      confirmation = described_class.create_for!(
        chapter:, sender:, subject: 'Update', message: 'Hello', recipient_ids: [1]
      )

      expect { confirmation.consume! { raise 'delivery failed' } }.to raise_error('delivery failed')
      expect(confirmation.reload.consumed_at).to be_nil
    end
  end
end
