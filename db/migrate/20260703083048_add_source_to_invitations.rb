class AddSourceToInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :invitations, :source, :string
  end
end
