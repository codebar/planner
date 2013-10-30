class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :short_description
      t.text :description
      t.integer :tutor_id, index: true
      t.datetime :date_and_time
      t.integer :seats, default: 0
      t.string :slug
      t.string :url

      t.timestamps
    end
  end
end
