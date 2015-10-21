class AddAccessibleToAddress < ActiveRecord::Migration
  def up
  	add_column :addresses, :note, :text
  	add_column :addresses, :accessible, :boolean, default: true
  	Address.update_all(accessible: true)
  end

  def down
  	remove_column :addresses, :note
  	remove_column :addresses, :accessible
  end
end
