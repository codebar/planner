class AddLevelToSponsors < ActiveRecord::Migration
  def up
    # hidden: 0,
    # standard: 1,
    # bronze: 2,
    # silver: 3,
    # gold: 4,
    add_column :sponsors, :level, :integer, null: false, default: 1, index: true
  end

  def down
    remove_column :sponsors, :level
  end
end
