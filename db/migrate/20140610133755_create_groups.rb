class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.references :chapter, index: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
