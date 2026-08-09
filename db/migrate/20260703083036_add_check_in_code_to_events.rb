class AddCheckInCodeToEvents < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :events, :check_in_code, :string
    add_index :events, :check_in_code, unique: true, algorithm: :concurrently
  end
end
