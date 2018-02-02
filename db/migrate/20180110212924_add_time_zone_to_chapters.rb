class AddTimeZoneToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :time_zone, :string, null: false, default: 'London'
  end
end
