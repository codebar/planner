class AddCityToAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :city, :string
  end
end
