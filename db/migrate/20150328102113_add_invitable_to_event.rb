class AddInvitableToEvent < ActiveRecord::Migration
  def change
    add_column :events, :invitable, :boolean, default: false
  end
end
