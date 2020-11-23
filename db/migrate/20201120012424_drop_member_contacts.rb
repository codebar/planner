class DropMemberContacts < ActiveRecord::Migration
  def change
    drop_table :member_contacts
  end
end
