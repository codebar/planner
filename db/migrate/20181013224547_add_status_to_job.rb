class AddStatusToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :status, :integer, default: 0
  end
end
