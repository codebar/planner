class CreateBans < ActiveRecord::Migration
  def change
    create_table :bans do |t|
      t.references :member, index: true
      t.datetime :expires_at
      t.string :reason
      t.text :note
      t.references :added_by, index: true

      t.timestamps
    end
  end
end
