class CreateMemberNotes < ActiveRecord::Migration
  def change
    create_table :member_notes do |t|
      t.references :member, index: true
      t.references :author, index: true
      t.text :note

      t.timestamps
    end
  end
end
