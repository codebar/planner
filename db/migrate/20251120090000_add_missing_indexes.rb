class AddMissingIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :invitations, :event_id unless index_exists?(:invitations, :event_id)
    add_index :invitations, :member_id unless index_exists?(:invitations, :member_id)
    add_index :workshop_invitations, :workshop_id unless index_exists?(:workshop_invitations, :workshop_id)
    add_index :workshop_invitations, :member_id unless index_exists?(:workshop_invitations, :member_id)
    add_index :events, :date_and_time unless index_exists?(:events, :date_and_time)
    add_index :workshops, :date_and_time unless index_exists?(:workshops, :date_and_time)
  end
end
