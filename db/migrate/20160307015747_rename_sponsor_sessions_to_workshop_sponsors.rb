class RenameSponsorSessionsToWorkshopSponsors < ActiveRecord::Migration
  def change
    rename_table :sponsor_sessions, :workshop_sponsors
  end
end
