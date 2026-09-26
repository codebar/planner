# frozen_string_literal: true

# One-off backfill for issue #2920: reconstruct tombstone rows for members who
# unsubscribed before subscriptions were soft-deleted. Reads both unsubscribe
# activity keys — subscription.removed (self-service, owner is the member) and
# subscription.admin_updated (admin path, the affected member is the recipient).
# Runs after the discard migration deploys; pairs that already have a row are
# skipped, so it is idempotent.
class SubscriptionTombstoneBackfill
  RESULT_FIELDS = %i[created skipped_existing skipped_missing_member].freeze

  Result = Data.define(*RESULT_FIELDS)

  # The member whose subscription ended: owner for self-service unsubscribes,
  # recipient for the admin path (the owner there is the acting admin).
  MEMBER_ID_SQL = <<~SQL.squish
    CASE WHEN activities.key = 'subscription.admin_updated' THEN activities.recipient_id
         ELSE activities.owner_id END
  SQL

  Pair = Data.define(:member_id, :group_id, :removed_at)

  def self.call(dry_run: false)
    new(dry_run:).call
  end

  def initialize(dry_run: false)
    @dry_run = dry_run
  end

  def call
    counts = RESULT_FIELDS.index_with { 0 }

    unsubscribe_pairs.each { |pair| counts[process(pair)] += 1 }

    Result.new(**counts)
  end

  private

  def process(pair)
    return :skipped_missing_member if pair_missing?(pair)
    return :skipped_existing if Subscription.exists?(member_id: pair.member_id, group_id: pair.group_id)

    create_tombstone(pair)
    :created
  end

  def pair_missing?(pair)
    !Member.exists?(pair.member_id) || !Group.exists?(pair.group_id)
  end

  def create_tombstone(pair)
    return if @dry_run

    Subscription.create!(member_id: pair.member_id, group_id: pair.group_id,
                         created_at: pair.removed_at, updated_at: pair.removed_at,
                         discarded_at: pair.removed_at)
  end

  # Latest unsubscribe event per member/group pair, across both activity keys.
  def unsubscribe_pairs
    PublicActivity::Activity
      .where(key: %w[subscription.removed subscription.admin_updated])
      .where.not(trackable_id: nil)
      .where("#{MEMBER_ID_SQL} IS NOT NULL")
      .group(Arel.sql(MEMBER_ID_SQL), 'trackable_id')
      .pluck(Arel.sql(MEMBER_ID_SQL.to_s), 'trackable_id', 'MAX(created_at)')
      .map { |member_id, group_id, removed_at| Pair.new(member_id:, group_id:, removed_at:) }
  end
end
