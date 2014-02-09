class RemoveTokenFromFeedbacks < ActiveRecord::Migration
  def change
    remove_column :feedbacks, :token, :string
  end
end
