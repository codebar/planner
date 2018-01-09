class CreateMeetingInvitation < ActiveRecord::Migration
  def change
    create_table :meeting_invitations do |t|
      t.references :meeting, index: true
      t.boolean :attending
      t.references :member, index: true
      t.string :role
      t.text :note
      t.string :token

      t.timestamps
    end
  end
end
