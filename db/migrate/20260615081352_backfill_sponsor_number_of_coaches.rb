class BackfillSponsorNumberOfCoaches < ActiveRecord::Migration[8.1]
  # Backfill nil number_of_coaches using the same formula as Sponsor#coach_spots
  # to ensure existing records pass the new presence validation when edited.
  def up
    Sponsor.where(number_of_coaches: nil)
           .update_all("number_of_coaches = ROUND(seats / 2.0)")
  end

  def down
    # Intentionally irreversible: we can't distinguish original nils from
    # intentionally-set values after backfill.
    raise ActiveRecord::IrreversibleMigration
  end
end
