class RemoveTokenFromFeedbacks < ActiveRecord::Migration
  def change
    remove_column :feedbacks, :token, :string
    remove_index :feedbacks, name: 'index_feedbacks_on_token'
  end
end
