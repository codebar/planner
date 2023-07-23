class DropMemberContacts < ActiveRecord::Migration[4.2]
  def change
    drop_table :member_contacts
  end
end
