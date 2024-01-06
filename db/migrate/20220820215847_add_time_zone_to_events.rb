class AddTimeZoneToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :time_zone, :string, null: false, default: 'London'
  end
end
