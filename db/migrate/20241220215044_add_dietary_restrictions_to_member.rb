class AddDietaryRestrictionsToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :dietary_restrictions, :string
  end
end
