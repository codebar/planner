class AddLevelToSponsorship < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsorships, :level, :string
  end
end
