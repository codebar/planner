class AddApproveByToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :approved_by_id, :integer, index: true
  end
end
