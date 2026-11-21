class CreatePairings < ActiveRecord::Migration[8.1]
  def change
    # A Pairing is a flexible group of invitations working together at an event
    # (0..n students + 0..n coaches), rather than fixed 1:1 columns. Keeping the
    # join table unconstrained supports multi-student/multi-coach and student-only
    # groups without future schema migrations.
    create_table :pairings do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :pairings, %i[event_id position]

    create_table :pairing_invitations do |t|
      t.references :pairing, null: false, foreign_key: true
      t.references :invitation, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
