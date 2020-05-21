class AddTutorialToWorkshopInvitation < ActiveRecord::Migration
  def change
    add_column :workshop_invitations, :tutorial, :text
  end
end
