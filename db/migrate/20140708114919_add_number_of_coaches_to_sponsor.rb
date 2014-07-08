class AddNumberOfCoachesToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :number_of_coaches, :integer, default: nil
  end
end
