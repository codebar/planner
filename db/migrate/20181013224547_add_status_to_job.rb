class AddStatusToJob < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :status, :integer, default: 0
  end
end
