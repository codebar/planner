class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.references :group, index: true
      t.references :member, index: true

      t.timestamps
    end
  end
end
