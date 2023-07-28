class AddVerifiedToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :verified, :boolean
  end
end
