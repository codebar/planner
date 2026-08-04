class AddUniqueIndexesForUniqueValidations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Production already had duplicate rows (a Rails uniqueness validation is not
    # atomic, so concurrent double-creates slipped through) that these unique
    # indexes would reject. Clean them first; this is a no-op on clean data.
    dedupe! :invitations, %i[member_id event_id role]
    dedupe! :workshop_invitations, %i[member_id workshop_id role]
    dedupe! :meeting_invitations, %i[member_id meeting_id]

    # if_not_exists: prod's release phase aborted midway on first run, leaving 5
    # of these indexes already created. Keep this migration safe to re-run.
    add_index :auth_services, %i[uid provider], unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :chapters, :name, unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :chapters, :email, unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :feedback_requests, %i[member_id workshop_id], unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :feedback_requests, :token, unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :invitations, %i[member_id event_id role], unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :meeting_invitations, %i[member_id meeting_id], unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :workshop_invitations, %i[member_id workshop_id role], unique: true, algorithm: :concurrently, if_not_exists: true
    add_index :workshop_sponsors, %i[sponsor_id workshop_id], unique: true, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :auth_services, %i[uid provider]
    remove_index :chapters, :name
    remove_index :chapters, :email
    remove_index :feedback_requests, %i[member_id workshop_id]
    remove_index :feedback_requests, :token
    remove_index :invitations, %i[member_id event_id role]
    remove_index :meeting_invitations, %i[member_id meeting_id]
    remove_index :workshop_invitations, %i[member_id workshop_id role]
    remove_index :workshop_sponsors, %i[sponsor_id workshop_id]
  end

  private

  # Keep the newest row per (columns) group, tie-breaking by lowest id, so a real
  # RSVP/verification update on any one row (e.g. attending=true) is never dropped.
  def dedupe!(table, columns)
    join = columns.map { |c| "i.#{c} = k.#{c}" }.join(' AND ')
    safety_assured do
      execute <<~SQL
        DELETE FROM #{table} AS i
        USING #{table} AS k
        WHERE #{join} AND (k.updated_at, -k.id) > (i.updated_at, -i.id)
      SQL
    end
  end
end
