class AddTitoUrlToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :tito_url, :string
  end
end
