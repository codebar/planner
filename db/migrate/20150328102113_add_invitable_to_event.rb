class AddInvitableToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :invitable, :boolean, default: false
  end
end
