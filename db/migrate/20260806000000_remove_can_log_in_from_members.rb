class RemoveCanLogInFromMembers < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :members, :can_log_in, :boolean }
  end
end
