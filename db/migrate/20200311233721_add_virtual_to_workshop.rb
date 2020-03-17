class AddVirtualToWorkshop < ActiveRecord::Migration
  def change
    add_column :workshops, :virtual, :boolean, default: false
  end
end
