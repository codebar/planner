class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :date_and_time
      t.datetime :ends_at
      t.references :venue, index: true

      t.timestamps
    end
  end
end
