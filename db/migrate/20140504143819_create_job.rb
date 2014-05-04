class CreateJob < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.string :location
      t.datetime :expiry_date
      t.string :email
      t.string :link_to_job
      t.references :created_by, index: true
      t.boolean :approved, default: false
      t. boolean :submitted, default: false

      t.timestamps
    end
  end
end
