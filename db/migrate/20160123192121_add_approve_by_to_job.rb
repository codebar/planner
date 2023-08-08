class AddApproveByToJob < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :approved_by_id, :integer, index: true
  end
end
