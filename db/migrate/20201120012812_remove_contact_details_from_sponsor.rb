class RemoveContactDetailsFromSponsor < ActiveRecord::Migration[4.2]
  def change
    remove_column :sponsors, :contact_first_name
    remove_column :sponsors, :contact_surname
    remove_column :sponsors, :email
  end
end
