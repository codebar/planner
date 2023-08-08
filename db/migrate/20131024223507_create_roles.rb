class CreateRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
