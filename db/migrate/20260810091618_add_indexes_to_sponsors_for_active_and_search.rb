class AddIndexesToSponsorsForActiveAndSearch < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :sponsors, :updated_at,
              order: { updated_at: :desc },
              where: 'level <> 0',
              algorithm: :concurrently,
              if_not_exists: true

    add_index :sponsors, 'lower(name)',
              algorithm: :concurrently,
              if_not_exists: true
  end
end
