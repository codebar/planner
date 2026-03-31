class CreateInvitationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :invitation_logs do |t|
      t.references :loggable, polymorphic: true, index: true
      t.references :initiator, foreign_key: { to_table: :members }, index: true
      t.references :chapter, index: true
      t.string :audience, null: false
      t.string :action, null: false, default: 'invite'
      t.integer :total_invitees, default: 0
      t.integer :success_count, default: 0
      t.integer :failure_count, default: 0
      t.integer :skipped_count, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.string :status, null: false, default: 'running'
      t.text :error_message
      t.datetime :expires_at
      t.timestamps
    end

    add_index :invitation_logs, :status
    add_index :invitation_logs, :created_at
    add_index :invitation_logs, :expires_at
    add_index :invitation_logs, %i[loggable_type loggable_id audience action status],
              name: 'index_invitation_logs_unique_active', unique: true,
              where: "status = 'running'"

    create_table :invitation_log_entries do |t|
      t.references :invitation_log, null: false, index: true, foreign_key: true
      t.references :member, null: false, index: true
      t.references :invitation, polymorphic: true
      t.string :status, null: false, default: 'success'
      t.text :failure_reason
      t.datetime :processed_at
      t.timestamps
    end

    add_index :invitation_log_entries, %i[invitation_log_id status]
    add_index :invitation_log_entries, %i[member_id processed_at]
    add_index :invitation_log_entries, %i[invitation_type invitation_id], unique: true
  end
end
