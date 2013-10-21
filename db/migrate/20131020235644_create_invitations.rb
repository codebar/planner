class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :sessions, index: true
      t.references :member, index: true
      t.boolean :attending
      t.boolean :attended
      t.text :note

      t.timestamps
    end
  end
end
