class AddContactsToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :member_id, :integer
    add_column :sponsors, :email, :string
    add_index :sponsors, :member_id
  end
end
