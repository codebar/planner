class UpdateContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :name, :string
    add_column :contacts, :surname, :string
    add_column :contacts, :email, :string
    add_column :contacts, :mailing_list_consent, :boolean, default: false
    remove_column :contacts, :member_id, :integer

    add_index :contacts, [:email, :sponsor_id], unique: true
  end
end
