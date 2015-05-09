class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :sponsor, index: true
      t.references :member, index: true

      t.timestamps
    end
  end
end
