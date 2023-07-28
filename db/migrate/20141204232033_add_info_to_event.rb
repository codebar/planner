class AddInfoToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :info, :string
  end
end
