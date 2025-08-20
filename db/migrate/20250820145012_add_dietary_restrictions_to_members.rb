class AddDietaryRestrictionsToMembers < ActiveRecord::Migration[7.0]
  def change
    change_table :members do |t|
      t.enum :dietary_restrictions, enum_type: "dietary_restriction_enum", array: true, default: []
    end
    add_column :members, :other_dietary_restrictions, :string
  end
end
