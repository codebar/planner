class AddCanLogInToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :can_log_in, :boolean, null: false, default: false
  end
end
