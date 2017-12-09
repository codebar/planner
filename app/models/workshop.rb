class Workshop < ActiveRecord::Base
  include Invitable
  include Listable

  attr_accessor :local_date, :local_time, :rsvp_open_local_date, :rsvp_open_local_time

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :invitations, class_name: 'WorkshopInvitation'
  has_many :workshop_sponsors
  has_many :sponsors, through: :workshop_sponsors
  has_many :organisers, -> { where('permissions.name' => 'organiser') }, through: :permissions, source: :members

  belongs_to :chapter

  default_scope { order('date_and_time DESC') }
  scope :students, -> { joins(:invitations).where(invitation: { name: 'Student', attended: true }) }
  scope :coaches, -> { joins(:invitations).where(invitations: { name: 'Coach', attended: true }) }

  validates :chapter_id, presence: true
  validates :date_and_time, presence: true

  before_validation :set_date_and_time
  before_validation :set_opens_at

  def host
    WorkshopSponsor.hosts.for_workshop(self.id).first.sponsor rescue nil
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
    WorkshopSponsor.exists?(host: true, workshop: self)
  end

  def has_valid_host?
    has_host? && host.address.present?
  end

  def past?
    date_and_time.past?
  end

  def rsvp_available?
    return rsvp_closes_at.future? if rsvp_closes_at
    future?
  end

  def future?
    date_and_time.future?
  end

  def open_for_rsvp?
    rsvp_opens_at && rsvp_opens_at.past?
  end

  def invitable_yet?
    open_for_rsvp? || invitable
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
    raise ArgumentError, 'Person should be a Member' unless person.is_a?(Member)
    WaitingList.students(self).include?(person) || WaitingList.coaches(self).include?(person)
  end

  def to_s
    'Workshop'
  end

  def location
    host.address.city rescue ''
  end

  def time_zone
    chapter.time_zone
  end

  def self.policy_class
    WorkshopPolicy
  end

  def date_and_time
    return nil unless super
    super.in_time_zone(time_zone)
  end

  def rsvp_opens_at
    return nil unless super
    super.in_time_zone(time_zone)
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  def time
    date_and_time.try(:time)
  end

  private

  def set_date_and_time
    new_date_and_time = datetime_from_fields(local_date, local_time)
    self.date_and_time = new_date_and_time if new_date_and_time
  end

  def set_opens_at
    new_opens_at = datetime_from_fields(rsvp_open_local_date, rsvp_open_local_time)
    self.rsvp_opens_at = new_opens_at if new_opens_at
  end

  def datetime_from_fields(date_string, time_string)
    return nil if date_string.blank? || time_string.blank? || !time_zone
    date = Date.parse(date_string)
    time = Time.parse(time_string)
    ActiveSupport::TimeZone[time_zone].local(date.year, date.month, date.day, time.hour, time.min)
  end
end
