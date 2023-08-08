class AddTutorialToWorkshopInvitation < ActiveRecord::Migration[4.2]
  def change
    add_column :workshop_invitations, :tutorial, :text
  end
end
