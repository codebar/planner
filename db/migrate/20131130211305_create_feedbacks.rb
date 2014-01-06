class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :tutorial, index: true
      t.text :request
      t.references :coach, index: true
      t.text :suggestions

      t.timestamps
    end
  end
end
