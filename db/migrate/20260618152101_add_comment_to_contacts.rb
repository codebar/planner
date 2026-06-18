class AddCommentToContacts < ActiveRecord::Migration[8.1]
  def change
    add_column :contacts, :comment, :text
  end
end
