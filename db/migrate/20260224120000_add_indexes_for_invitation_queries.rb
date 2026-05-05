class AddIndexesForInvitationQueries < ActiveRecord::Migration[8.1]
  def change
    add_index :workshop_invitations, %i[member_id attending], name: 'index_workshop_invitations_member_attending'
    add_index :workshop_invitations, %i[workshop_id attending], name: 'index_workshop_invitations_workshop_attending'

    add_index :meeting_invitations, %i[member_id attending], name: 'index_meeting_invitations_member_attending'
    add_index :meeting_invitations, %i[meeting_id attending], name: 'index_meeting_invitations_meeting_attending'

    add_index :invitations, %i[member_id attending], name: 'index_invitations_member_attending'
    add_index :invitations, %i[event_id attending], name: 'index_invitations_event_attending'
  end
end
