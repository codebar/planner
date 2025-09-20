class AddHowYouFoundUsOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :how_you_found_us, :integer
    add_column :members, :how_you_found_us_other_reason, :string
  end
end
