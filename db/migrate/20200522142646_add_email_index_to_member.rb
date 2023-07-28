class AddEmailIndexToMember < ActiveRecord::Migration[4.2]
  def change
    add_index :members, :email, unique: true
  end
end
