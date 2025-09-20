class AddHowYouFoundUsOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :how_you_found_us, :text, array: true, default: []
  end
end
