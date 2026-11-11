class Subscription < ApplicationRecord
  include Discard::Model

  belongs_to :group
  belongs_to :member
  has_one :chapter, through: :group

  # Uniqueness applies to active subscriptions only; discarded rows are kept as
  # tombstones so signup-nudge eligibility can tell 'never subscribed' apart from
  # 'subscribed then unsubscribed' (issue #2920). The partial unique index
  # (index_subscriptions_on_member_id_group_id_active) enforces this at the DB level.
  validates :group, uniqueness: { scope: :member_id, conditions: -> { kept } }

  # Tombstone rows created by SubscriptionTombstoneBackfill carry the
  # unsubscribe time in created_at, so they are not sign-ups for that month.
  # Genuine churned subscriptions keep their own created_at and do count.
  scope :excluding_backfilled_tombstones,
        -> { where('subscriptions.discarded_at IS NULL OR subscriptions.discarded_at <> subscriptions.created_at') }

  def student?
    group.name.casecmp('students').zero?
  end

  def coach?
    group.name.casecmp('coaches').zero?
  end
end
