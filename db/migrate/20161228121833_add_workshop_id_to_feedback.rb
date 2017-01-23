class AddWorkshopIdToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :workshop_id, :integer
  end
end
