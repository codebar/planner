class RemoveTokenFromFeedbacks < ActiveRecord::Migration[4.2]
  def change
    remove_column :feedbacks, :token, :string
  end
end
