class AddTargetGroupToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :audience, :string
  end
end
