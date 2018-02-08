class AddAccessibilityInfoToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :accessibility_info, :text
  end
end
