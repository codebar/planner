# frozen_string_literal: true

class AddDiscardedAtToSubscriptions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    unless column_exists?(:subscriptions, :discarded_at)
      add_column :subscriptions, :discarded_at, :datetime
      add_index :subscriptions, :discarded_at, algorithm: :concurrently
    end

    safety_assured do
      # A tombstoned row must not block resubscribing: uniqueness now applies to
      # active subscriptions only. Add before drop so existing uniqueness holds
      # throughout (see 20260408220120 for the concurrent-index precedent).
      unless index_exists?(:subscriptions, name: 'index_subscriptions_on_member_id_group_id_active')
        add_index :subscriptions, %i[member_id group_id],
                  unique: true,
                  name: 'index_subscriptions_on_member_id_group_id_active',
                  where: 'discarded_at IS NULL',
                  algorithm: :concurrently
      end

      remove_index :subscriptions, name: 'index_subscriptions_on_member_id_group_id'
    end
  end

  def down
    # A failed rebuild (duplicate pairs) leaves an invalid index that index_exists? treats as
    # present, so a retry would skip the rebuild and silently drop every tombstone. Fail loudly
    # before touching anything instead.
    duplicate_pair_count = select_value(<<~SQL).to_i
      SELECT count(*) FROM (
        SELECT 1 FROM subscriptions
        GROUP BY member_id, group_id
        HAVING count(*) > 1
      ) duplicated_pairs
    SQL

    if duplicate_pair_count.positive?
      raise ActiveRecord::MigrationError, <<~MSG
        Cannot revert: member/group pairs exist as both active subscriptions and tombstones, so
        the old unique index on (member_id, group_id) cannot be rebuilt. Delete the tombstoned
        rows (subscriptions with discarded_at set) and drop any invalid index named
        index_subscriptions_on_member_id_group_id, then retry this rollback.
      MSG
    end

    safety_assured do
      unless index_exists?(:subscriptions, name: 'index_subscriptions_on_member_id_group_id')
        add_index :subscriptions, %i[member_id group_id],
                  unique: true,
                  name: 'index_subscriptions_on_member_id_group_id',
                  algorithm: :concurrently
      end

      remove_index :subscriptions, name: 'index_subscriptions_on_member_id_group_id_active'
      remove_index :subscriptions, :discarded_at
      remove_column :subscriptions, :discarded_at
    end
  end
end
