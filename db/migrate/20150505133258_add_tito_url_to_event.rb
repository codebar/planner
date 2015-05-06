class AddTitoUrlToEvent < ActiveRecord::Migration
  def change
    add_column :events, :tito_url, :string
  end
end
