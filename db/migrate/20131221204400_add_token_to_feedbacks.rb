class AddTokenToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :token, :string
    add_index :feedbacks, :token, unique: true
  end
end
