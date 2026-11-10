class CreateChapterContactConfirmations < ActiveRecord::Migration[8.1]
  def change
    create_table :chapter_contact_confirmations do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :members }
      t.string :token_digest, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.jsonb :recipient_ids, null: false, default: []
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.timestamps
    end

    add_index :chapter_contact_confirmations, :token_digest, unique: true
    add_index :chapter_contact_confirmations, :expires_at
  end
end
