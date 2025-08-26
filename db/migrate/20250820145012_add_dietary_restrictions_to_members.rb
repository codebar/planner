class AddDietaryRestrictionsToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :dietary_restrictions, :enum, enum_type: "dietary_restriction_enum", array: true, default: []
    add_column :members, :other_dietary_restrictions, :string
  end
end
