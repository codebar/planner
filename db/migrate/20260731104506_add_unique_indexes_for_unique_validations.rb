class AddUniqueIndexesForUniqueValidations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :auth_services, %i[uid provider], unique: true, algorithm: :concurrently
    add_index :chapters, :name, unique: true, algorithm: :concurrently
    add_index :chapters, :email, unique: true, algorithm: :concurrently
    add_index :feedback_requests, %i[member_id workshop_id], unique: true, algorithm: :concurrently
    add_index :feedback_requests, :token, unique: true, algorithm: :concurrently
    add_index :invitations, %i[member_id event_id role], unique: true, algorithm: :concurrently
    add_index :meeting_invitations, %i[member_id meeting_id], unique: true, algorithm: :concurrently
    add_index :workshop_invitations, %i[member_id workshop_id role], unique: true, algorithm: :concurrently
    add_index :workshop_sponsors, %i[sponsor_id workshop_id], unique: true, algorithm: :concurrently
  end
end
