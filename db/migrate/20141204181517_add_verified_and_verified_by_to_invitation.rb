class AddVerifiedAndVerifiedByToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :verified, :boolean
    add_reference :invitations, :verified_by, index: true
  end
end
