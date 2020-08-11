class AddLevelToSponsorship < ActiveRecord::Migration
  def change
    add_column :sponsorships, :level, :string
  end
end
