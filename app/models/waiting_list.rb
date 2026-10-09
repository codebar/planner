class WaitingList < ApplicationRecord
  belongs_to :invitation, class_name: 'WorkshopInvitation'

  has_one :workshop, through: :invitation
  has_one :member, through: :invitation

  scope :by_workshop, ->(workshop) { joins(:invitation).where('workshop_invitations.workshop_id = ?', workshop.id) }
  scope :where_role, ->(role) { where('workshop_invitations.role = ?', role) }
  scope :with_notes_and_their_authors, -> { includes(member: [{ member_notes: :author }, :attendance_warnings]) }

  def self.add(invitation, auto_rsvp = true)
    find_or_create_by(invitation:) do |waiting_list|
      waiting_list.auto_rsvp = auto_rsvp
    end
  end

  def self.students(workshop)
    by_workshop(workshop).where_role('Student').where(auto_rsvp: true).map(&:member)
  end

  def self.coaches(workshop)
    by_workshop(workshop).where_role('Coach').where(auto_rsvp: true).map(&:member)
  end

  # Pops the next auto-RSVP waitlist entry and confirms its invitation. The
  # caller sends the attendance email for the promoted invitation.
  def self.promote_next(workshop, role)
    transaction do
      # SKIP LOCKED lets a concurrent promoter that holds another freed seat
      # take the next entry instead of racing on this one.
      next_spot = by_workshop(workshop).where_role(role).where(auto_rsvp: true)
                                       .order(:created_at).lock('FOR UPDATE SKIP LOCKED').first
      return unless next_spot

      invitation = next_spot.invitation
      next_spot.destroy!
      invitation.update!(attending: true, rsvp_time: Time.zone.now, automated_rsvp: true)
      invitation
    end
  end

  def self.coaches_for(workshop)
    by_workshop(workshop).where_role('Coach').order(:created_at)
  end

  def self.students_for(workshop)
    by_workshop(workshop).where_role('Student').order(:created_at)
  end
end
