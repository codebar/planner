class AddCityToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :city, :string
  end
end
