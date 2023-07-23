class CreateSponsorships < ActiveRecord::Migration[4.2]
  def change
    create_table :sponsorships do |t|
      t.references :event, index: true
      t.references :sponsor, index: true

      t.timestamps
    end
  end
end
