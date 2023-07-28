class CreateAuthServices < ActiveRecord::Migration[4.2]
  def change
    create_table :auth_services do |t|
      t.references :member, index: true
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
