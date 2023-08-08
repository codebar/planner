class CreateAddress < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.string :flat
      t.string :street
      t.string :postal_code
      t.belongs_to :sponsor
      t.timestamps
    end
  end
end
