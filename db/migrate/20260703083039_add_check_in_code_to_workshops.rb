class AddCheckInCodeToWorkshops < ActiveRecord::Migration[8.1]
  def change
    add_column :workshops, :check_in_code, :string
    add_index :workshops, :check_in_code, unique: true
  end
end
