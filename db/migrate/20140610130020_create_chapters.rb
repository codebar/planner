class CreateChapters < ActiveRecord::Migration[4.2]
  def change
    create_table :chapters do |t|
      t.string :name
      t.string :city

      t.timestamps
    end
  end
end
