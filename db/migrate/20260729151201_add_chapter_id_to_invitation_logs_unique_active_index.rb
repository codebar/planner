class AddChapterIdToInvitationLogsUniqueActiveIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_index :invitation_logs,
                 name: 'index_invitation_logs_unique_active',
                 algorithm: :concurrently

    add_index :invitation_logs,
              %i[loggable_type loggable_id chapter_id audience action status],
              unique: true,
              where: "status = 'running'",
              name: 'index_invitation_logs_unique_active',
              algorithm: :concurrently
  end

  def down
    remove_index :invitation_logs,
                 name: 'index_invitation_logs_unique_active',
                 algorithm: :concurrently

    add_index :invitation_logs,
              %i[loggable_type loggable_id audience action status],
              unique: true,
              where: "status = 'running'",
              name: 'index_invitation_logs_unique_active',
              algorithm: :concurrently
  end
end
