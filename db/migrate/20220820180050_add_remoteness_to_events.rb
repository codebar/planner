class AddRemotenessToEvents < ActiveRecord::Migration
  def change
    add_column :events, :virtual, :boolean, null: false, default: false
  end
end
