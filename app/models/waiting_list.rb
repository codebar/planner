class WaitingList < ActiveRecord::Base
  has_one :workshop, through: :invitation
  belongs_to :invitation, class: SessionInvitation

  scope :by_workshop, -> (workshop) { joins(:invitation).where("session_invitations.sessions_id = ?", workshop.id) }
  scope :next_spot, -> (workshop, role) { by_workshop(workshop).where_role|(role).where(auto_rsvp: true).first rescue false }

  scope :where_role, -> (workshop, role) { where("session_invitations.role = ?", role) }

  def self.add(invitation, auto_rsvp=true)
    create(invitation: invitation, auto_rsvp: auto_rsvp)
  end
end
