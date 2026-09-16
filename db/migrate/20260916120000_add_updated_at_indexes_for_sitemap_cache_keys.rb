class AddUpdatedAtIndexesForSitemapCacheKeys < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :workshops, :updated_at, algorithm: :concurrently
    add_index :events, :updated_at, algorithm: :concurrently
    add_index :meetings, :updated_at, algorithm: :concurrently
  end
end
