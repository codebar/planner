class WaitingList < ActiveRecord::Base
  has_one :workshop, through: :invitation
  has_one :member, through: :invitation
  belongs_to :invitation, class_name: 'SessionInvitation'

  scope :by_workshop, -> (workshop) { joins(:invitation).where("session_invitations.sessions_id = ?", workshop.id) }
  scope :where_role, -> (role) { where("session_invitations.role = ?", role) }

  def self.add(invitation, auto_rsvp=true)
    create(invitation: invitation, auto_rsvp: auto_rsvp)
  end

  def self.students(workshop)
    by_workshop(workshop).where_role('Student').where(auto_rsvp: true).map(&:member)
  end

  def self.coaches(workshop)
    by_workshop(workshop).where_role('Coach').where(auto_rsvp: true).map(&:member)
  end

  def self.waiting_for(workshop, role)
    by_workshop(workshop).where_role(role).where(auto_rsvp: true)
  end

  def self.next_spot(workshop, role)
    self.waiting_for(workshop, role).first
  end
end
