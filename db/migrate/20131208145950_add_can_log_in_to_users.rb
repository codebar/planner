class AddCanLogInToUsers < ActiveRecord::Migration
  def change
    add_column :members, :can_log_in, :boolean, null: false, default: false
  end
end
