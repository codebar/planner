class RemoveVerifiedFromUser < ActiveRecord::Migration
  def change
    remove_column :members, :verified
  end
end
