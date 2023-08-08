class AddTokenToContact < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :token, :string, null: false
  end
end
