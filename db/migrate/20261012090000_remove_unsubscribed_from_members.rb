class RemoveUnsubscribedFromMembers < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :members, :unsubscribed, :boolean }
  end
end
