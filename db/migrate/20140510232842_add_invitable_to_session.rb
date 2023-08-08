class AddInvitableToSession < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :invitable, :boolean, default: true
    add_column :sessions, :sign_up_url, :string
  end
end
