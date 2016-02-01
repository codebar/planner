class ChangeMeetingFields < ActiveRecord::Migration
  def change
    add_column :meetings, :invitable, :boolean
    add_column :meetings, :spaces, :integer
    add_column :meetings, :sponsor_id, :integer

    remove_column :meetings, :lanyrd_url
    remove_column :meetings, :duration
  end
end
