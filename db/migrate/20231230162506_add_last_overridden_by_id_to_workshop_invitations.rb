class AddLastOverriddenByIdToWorkshopInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :workshop_invitations, :last_overridden_by_id, :integer, default: nil
  end
end
