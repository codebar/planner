class AddTargetGroupToEvent < ActiveRecord::Migration
  def change
    add_column :events, :audience, :string
  end
end
