class AddUniqueIndexToWaitingListsInvitationId < ActiveRecord::Migration[8.1]
  def up
    # Clean up duplicate waiting list entries
    duplicate_count = say_with_time "Cleaning up duplicate waiting list entries" do
      duplicate_invitation_ids = WaitingList
        .group(:invitation_id)
        .having('COUNT(*) > 1')
        .pluck(:invitation_id)

      duplicate_count = duplicate_invitation_ids.count
      say "Found #{duplicate_count} invitation_ids with duplicates"

      if duplicate_count > 0
        # For each duplicate set, keep oldest and delete the rest
        duplicate_invitation_ids.each do |invitation_id|
          entries = WaitingList
            .where(invitation_id: invitation_id)
            .order(:created_at)

          # Get IDs to delete (all except first/oldest)
          ids_to_delete = entries[1..].map(&:id)
          deleted_count = ids_to_delete.size

          say "  Invitation #{invitation_id}: deleting #{deleted_count} duplicate(s), keeping entry ##{entries.first.id}"

          # Use delete_all for performance and to avoid callbacks
          WaitingList.where(id: ids_to_delete).delete_all
        end
      end

      duplicate_count
    end

    # Add unique constraint (remove existing non-unique index first if it exists)
    say_with_time "Adding unique index on waiting_lists.invitation_id" do
      begin
        remove_index :waiting_lists, :invitation_id
      rescue StandardError => e
        say "  Note: Could not remove existing index (#{e.message})"
      end

      add_index :waiting_lists, :invitation_id, unique: true
    end
  end

  def down
    begin
      remove_index :waiting_lists, :invitation_id
    rescue StandardError => e
      say "Could not remove index: #{e.message}"
    end
    # Note: Cannot restore deleted duplicate entries
  end
end
