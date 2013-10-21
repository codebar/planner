class AddUnsubscribedToMember < ActiveRecord::Migration
  def change
    add_column :members, :unsubscribed, :boolean
  end
end
