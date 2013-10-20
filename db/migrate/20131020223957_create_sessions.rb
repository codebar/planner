class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :title
      t.text :description
      t.datetime :date_and_time

      t.timestamps
    end
  end
end
