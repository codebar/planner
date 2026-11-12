class ChapterContactConfirmation < ApplicationRecord
  LIFETIME = 30.minutes

  belongs_to :chapter
  belongs_to :sender, class_name: 'Member'

  validates :token_digest, :subject, :message, :expires_at, presence: true
  validates :token_digest, uniqueness: true
  validates :recipient_ids, presence: true

  attr_accessor :token

  def self.find_for(chapter:, sender:, token:)
    return unless token.is_a?(String) && token.present?

    find_by(chapter:, sender:, token_digest: Digest::SHA256.hexdigest(token))
  end

  def self.create_for!(chapter:, sender:, subject:, message:, recipient_ids:)
    token = SecureRandom.urlsafe_base64(32)
    create!(
      chapter:,
      sender:,
      subject:,
      message:,
      recipient_ids: recipient_ids.uniq,
      token_digest: Digest::SHA256.hexdigest(token),
      expires_at: LIFETIME.from_now
    ).tap { |confirmation| confirmation.token = token }
  end

  def consume!(now: Time.current)
    consumed = false
    with_lock do
      if usable_at?(now)
        update!(consumed_at: now)
        yield self
        consumed = true
      end
    end
    consumed
  end

  def usable_at?(time)
    consumed_at.nil? && expires_at > time
  end
end
