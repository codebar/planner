class RemoveGlobalUniqueConstraintFromInvitationLogEntries < ActiveRecord::Migration[8.1]
  def up
    remove_index :invitation_log_entries,
                 name: 'idx_on_invitation_type_invitation_id_6d6ef495e6'
  end

  def down
    add_index :invitation_log_entries,
              %i[invitation_type invitation_id],
              name: 'idx_on_invitation_type_invitation_id_6d6ef495e6',
              unique: true
  end
end
