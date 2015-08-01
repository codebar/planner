class CreateMemberContacts < ActiveRecord::Migration
  def change
    create_table :member_contacts do |t|
      t.integer :sponsor_id
      t.integer :member_id
      t.timestamps
    end
  end
end
