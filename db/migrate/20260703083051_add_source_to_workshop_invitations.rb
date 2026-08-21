class AddSourceToWorkshopInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :workshop_invitations, :source, :string
  end
end
