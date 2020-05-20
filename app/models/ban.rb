class Ban < ActiveRecord::Base
  belongs_to :member
  belongs_to :added_by, class_name: 'Member'

  validates :expires_at, :reason, :note, :added_by, presence: true

  validate :valid_expiry_date?

  scope :active, -> { where('expires_at > ?', Date.current) }
  scope :permanent, -> { where(permanent: true) }

  def active?
    expires_at.future?
  end

  private

  def valid_expiry_date?
    errors.add(:expires_at, 'must be in the future') unless expires_at.try(:future?)
  end
end
