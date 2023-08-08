class AddVirtualToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :virtual, :boolean, null: false, default: false
  end
end
