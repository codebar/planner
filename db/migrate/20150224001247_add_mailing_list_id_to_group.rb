class AddMailingListIdToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :mailing_list_id, :string
  end
end
