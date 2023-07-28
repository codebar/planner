class AddRatingToFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :rating, :integer
  end
end
