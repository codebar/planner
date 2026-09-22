class AddUpdatedAtIndexesForSitemapCacheKeys < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # if_not_exists keeps a re-run after a partial concurrent-index failure
    # (an INVALID or half-built index) from failing the next deploy.
    add_index :workshops, :updated_at, algorithm: :concurrently, if_not_exists: true
    add_index :events, :updated_at, algorithm: :concurrently, if_not_exists: true
    add_index :meetings, :updated_at, algorithm: :concurrently, if_not_exists: true
  end
end
