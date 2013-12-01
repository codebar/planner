class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :name
      t.text :description
      t.string :url
      t.references :course, index: true

      t.timestamps
    end
  end
end
