class AddVerifiedAndVerifiedByToInvitation < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :verified, :boolean
    add_reference :invitations, :verified_by, index: true
  end
end
