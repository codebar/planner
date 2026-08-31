class AddUniqueIndexOnMemberEmailDeliveriesMemberAndType < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :member_email_deliveries, %i[member_id email_type], unique: true, algorithm: :concurrently
  end
end
