class Ban < ActiveRecord::Base
  belongs_to :member
  belongs_to :added_by, class_name: 'Member'

  validates :reason, :note, :added_by, presence: true

  validate :valid_expiry_date?

  scope :active, -> { where('expires_at > ?', Date.current) }
  scope :permanent, -> { where(permanent: true) }

  def active?
    expires_at.future?
  end

  def expiry_in_words
    'There is a permanent ban on the user' if permanent
    expires_at
  end

  private

  def valid_expiry_date?
    errors.add(:expires_at, 'must be in the future') unless expires_at.try(:future?)
  end
end
