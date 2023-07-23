class RenameSponsorSessionsToWorkshopSponsors < ActiveRecord::Migration[4.2]
  def change
    rename_table :sponsor_sessions, :workshop_sponsors
  end
end
