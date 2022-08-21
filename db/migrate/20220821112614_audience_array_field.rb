class AudienceArrayField < ActiveRecord::Migration
  def change
    change_column :events, :audience, :string, array: true, using: "(string_to_array(audience, ','))"
  end

end
