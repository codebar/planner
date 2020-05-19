class WaitingList < ActiveRecord::Base
  belongs_to :invitation, class_name: 'WorkshopInvitation'

  has_one :workshop, through: :invitation
  has_one :member, through: :invitation

  scope :by_workshop, ->(workshop) { joins(:invitation).where('workshop_invitations.workshop_id = ?', workshop.id) }
  scope :where_role, ->(role) { where('workshop_invitations.role = ?', role) }

  def self.add(invitation, auto_rsvp = true)
    create(invitation: invitation, auto_rsvp: auto_rsvp)
  end

  def self.students(workshop)
    by_workshop(workshop).where_role('Student').where(auto_rsvp: true).map(&:member)
  end

  def self.coaches(workshop)
    by_workshop(workshop).where_role('Coach').where(auto_rsvp: true).map(&:member)
  end

  def self.next_spot(workshop, role)
    by_workshop(workshop).where_role(role).where(auto_rsvp: true).first
  end
end
