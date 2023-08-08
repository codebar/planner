class AddTimeZoneToChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :time_zone, :string, null: false, default: 'London'
  end
end
