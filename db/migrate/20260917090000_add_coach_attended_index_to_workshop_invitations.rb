class AddCoachAttendedIndexToWorkshopInvitations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index :workshop_invitations, :member_id,
              where: "attended AND role = 'Coach'",
              name: :index_workshop_invitations_coach_attended_on_member_id,
              algorithm: :concurrently
  end

  def down
    remove_index :workshop_invitations,
                 name: :index_workshop_invitations_coach_attended_on_member_id,
                 algorithm: :concurrently
  end
end
