class FixDuplicateSubscriptionsAndAddUniqueIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      DELETE FROM subscriptions
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM subscriptions
        GROUP BY member_id, group_id
      )
      AND (member_id, group_id) IN (
        SELECT member_id, group_id
        FROM subscriptions
        GROUP BY member_id, group_id
        HAVING COUNT(*) > 1
      )
    SQL

    add_index :subscriptions,
              %i[member_id group_id],
              unique: true,
              name: 'index_subscriptions_on_member_id_group_id',
              algorithm: :concurrently
  end

  def down
    remove_index :subscriptions, name: 'index_subscriptions_on_member_id_group_id'
  end
end
