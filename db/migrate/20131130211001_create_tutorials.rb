class CreateTutorials < ActiveRecord::Migration[4.2]
  def change
    create_table :tutorials do |t|
      t.string :name
      t.text :description
      t.string :url
      t.references :sessions, index: true

      t.timestamps
    end
  end
end
