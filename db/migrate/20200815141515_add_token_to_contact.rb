class AddTokenToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :token, :string, null: false
  end
end
