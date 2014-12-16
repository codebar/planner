class AddInfoToEvent < ActiveRecord::Migration
  def change
    add_column :events, :info, :string
  end
end
