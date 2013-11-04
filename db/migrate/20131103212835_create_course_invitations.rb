class CreateCourseInvitations < ActiveRecord::Migration
  def change
    create_table :course_invitations do |t|
      t.references :course, index: true
      t.references :member, index: true
      t.boolean :attending
      t.boolean :attended
      t.text :note
      t.string :token

      t.timestamps
    end
  end
end
