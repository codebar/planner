class AddUnsubscribedToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :unsubscribed, :boolean
  end
end
