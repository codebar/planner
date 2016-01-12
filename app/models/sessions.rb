class Sessions < ActiveRecord::Base
  include Invitable
  include Listable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions
  has_many :organisers, -> { where("permissions.name" => "organiser") }, through: :permissions, source: :members


  belongs_to :chapter

  default_scope { order('date_and_time DESC') }
  scope :students, -> { joins(:invitations).where(invitation: { name: 'Student', attended: true }) }
  scope :coaches, -> { joins(:invitations).where(invitations: { name: 'Coach', attended: true  }) }

  validates :chapter_id, presence: true

  before_save :combine_date_and_time, :set_rsvp_close_time, :schedule_allocation

  def host
    SponsorSession.hosts.for_session(self.id).first.sponsor rescue nil
  end

  def waiting_list
    WaitingList.by_workshop(self).map(&:invitation)
  end

  def waiting_list_count_for(role)
    WaitingList.by_workshop(self).where_role(role).where(auto_rsvp: true).count
  end

  def student_waiting_list
    waiting_list.select(&:for_student?)
  end

  def coach_waiting_list
    waiting_list.select(&:for_coach?)
  end

  def has_host?
    SponsorSession.exists?(host: true, sessions: self)
  end

  def has_valid_host?
    has_host? and host.address.present?
  end

  def past?
    date_and_time.past?
  end

  def today?
    date_and_time.today?
  end

  def rsvp_available?
    future? && rsvp_close_time.future?
  end

  def can_accept?
    random_allocate_at.nil? or random_allocate_at.past?
  end

  # nil if allocations are being made immediately, otherwise the time
  # when allocations will be made
  def allocation_time
    can_accept? ? nil : random_allocate_at
  end

  def future?
    date_and_time.future?
  end

  def coach_spaces?
    not host.nil? and host.coach_spots > attending_coaches.length
  end

  def student_spaces?
    not host.nil? and host.seats > attending_students.length
  end

  # Is this person attending this event?
  def attendee?(person)
    return false if person.nil?
    raise ArgumentError, "Person should be a Member, not a #{person.class}" unless person.is_a? Member
    attending_students.map(&:member).include?(person) || attending_coaches.map(&:member).include?(person)
  end

  # Is this person on the waiting list for this event?
  def waitlisted?(person)
    return false if person.nil?
    raise ArgumentError, "Person should be a Member" unless person.is_a?(Member)
    WaitingList.students(self).include?(person) || WaitingList.coaches(self).include?(person)
  end

  def to_s
    "Workshop"
  end

  def location
    host.address.city rescue ""
  end

  def self.policy_class
    WorkshopPolicy
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  private

  def combine_date_and_time
    self.date_and_time = date_and_time.change(hour: time.hour, min: time.min)
  end

  def set_rsvp_close_time
    self.rsvp_close_time ||= self.date_and_time
  end

  def schedule_allocation
    if allocation_time and random_allocate_at_changed?
      AllocateSpacesJob.perform_when_needed(self)
    end
  end

end
