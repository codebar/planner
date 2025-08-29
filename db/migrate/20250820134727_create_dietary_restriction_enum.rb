class CreateDietaryRestrictionEnum < ActiveRecord::Migration[7.0]
  def change
    create_enum :dietary_restriction_enum, %w[vegan vegetarian pescetarian halal gluten_free dairy_free other]
  end
end
