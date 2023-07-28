class AddVirtualToWorkshop < ActiveRecord::Migration[4.2]
  def change
    add_column :workshops, :virtual, :boolean, default: false
  end
end
