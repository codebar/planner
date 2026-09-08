class AddCreatedByIdIndexToWorkshops < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :workshops, :created_by_id, algorithm: :concurrently
  end
end
