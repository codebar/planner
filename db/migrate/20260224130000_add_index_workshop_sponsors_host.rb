class AddIndexWorkshopSponsorsHost < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_index :workshop_sponsors, %i[workshop_id host], name: 'index_workshop_sponsors_on_workshop_id_and_host'
    end
  end
end
