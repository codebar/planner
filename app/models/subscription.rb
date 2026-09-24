class Subscription < ApplicationRecord
  include Discard::Model

  belongs_to :group
  belongs_to :member
  has_one :chapter, through: :group

  # Uniqueness applies to active subscriptions only; discarded rows are kept as
  # tombstones so signup-nudge eligibility can tell 'never subscribed' apart from
  # 'subscribed then unsubscribed' (issue #2920).
  validates :group, uniqueness: { scope: :member_id, conditions: -> { kept } }
  validate :no_active_duplicate, on: :create
  scope :ordered, -> { order(created_at: :desc) }

  before_discard :check_active_uniqueness

  private

  # #discard skips validations (it writes via update_attribute), so the guard
  # against resubscribing twice without an unsubscribe runs here instead.
  def check_active_uniqueness
    return if discarded_at.present?

    duplicates = member.subscriptions.kept.where.not(id:).exists?
    errors.add(:member, 'already has an active subscription for this group') if duplicates
  end

  def no_active_duplicate
    return unless group_id && member_id

    scope = member.subscriptions.kept.where(group_id:)
    errors.add(:group, 'already subscribed') if scope.where.not(id:).exists?
  end

  def student?
    group.name.casecmp('students').zero?
  end

  def coach?
    group.name.casecmp('coaches').zero?
  end
end
