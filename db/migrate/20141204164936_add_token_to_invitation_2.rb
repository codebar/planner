class AddTokenToInvitation2 < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :token, :string
  end
end
