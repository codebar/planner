class AddInvitableToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :invitable, :boolean, default: true
    add_column :sessions, :sign_up_url, :string
  end
end
