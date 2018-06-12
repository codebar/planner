class AddDirectionsToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :directions, :text
  end
end
