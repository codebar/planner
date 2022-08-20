class AddRemotenessToEvents < ActiveRecord::Migration
  def change
    add_column :events, :remote, :boolean, null: false, default: false
  end
end
