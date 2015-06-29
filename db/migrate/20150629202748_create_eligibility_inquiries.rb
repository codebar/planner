class CreateEligibilityInquiries < ActiveRecord::Migration
  def change
    create_table :eligibility_inquiries do |t|
      t.references :member, index: true
      t.references :sent_by, index: true

      t.timestamps
    end
  end
end
