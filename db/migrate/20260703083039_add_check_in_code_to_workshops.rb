class AddCheckInCodeToWorkshops < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :workshops, :check_in_code, :string
    add_index :workshops, :check_in_code, unique: true, algorithm: :concurrently
  end
end
