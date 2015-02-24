class AddMailingListIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :mailing_list_id, :string
  end
end
