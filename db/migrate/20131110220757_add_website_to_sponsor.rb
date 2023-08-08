class AddWebsiteToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :website, :string
  end
end
