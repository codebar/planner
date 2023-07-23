class RemoveVerifiedFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :members, :verified
  end
end
