class AddNumberOfCoachesToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :number_of_coaches, :integer, default: nil
  end
end
