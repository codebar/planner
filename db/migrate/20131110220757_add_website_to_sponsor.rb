class AddWebsiteToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :website, :string
  end
end
