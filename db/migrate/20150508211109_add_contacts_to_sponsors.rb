class AddContactsToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :email, :string
    add_column :sponsors, :contact_first_name, :string
    add_column :sponsors, :contact_surname, :string
  end
end
