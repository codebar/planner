class AddMoreDataToBans < ActiveRecord::Migration
  def change
    add_column :bans, :permanent, :boolean, default: false
    add_column :bans, :explanation, :text
  end
end
