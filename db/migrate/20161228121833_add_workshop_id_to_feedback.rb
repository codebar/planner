class AddWorkshopIdToFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :workshop_id, :integer
  end
end
