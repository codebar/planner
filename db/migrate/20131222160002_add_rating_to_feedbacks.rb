class AddRatingToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :rating, :integer
  end
end
