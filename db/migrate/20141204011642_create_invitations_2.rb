class CreateInvitations2 < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :event, index: true
      t.boolean :attending
      t.references :member, index: true
      t.string :role
      t.text :note

      t.timestamps
    end
  end
end
