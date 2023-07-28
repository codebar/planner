class AddTokenToFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :token, :string
    add_index :feedbacks, :token, unique: true
  end
end
