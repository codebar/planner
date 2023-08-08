class AddSlugToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :slug, :string
  end
end
