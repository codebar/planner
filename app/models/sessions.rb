class Sessions < ActiveRecord::Base
  include Invitable
  include Listable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions

  belongs_to :chapter

  scope :students, -> { joins(:invitations).where(invitation: { name: 'Student', attended: true }) }
  scope :coaches, -> { joins(:invitations).where(invitations: { name: 'Coach', attended: true  }) }

  validates :chapter_id, presence: true

  default_scope { order('date_and_time DESC') }

  def host
    SponsorSession.hosts.for_session(self.id).first.sponsor rescue nil
  end

  def waiting_list
    invitations
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


  # Is this event in the past?
  def past?
    combined_date_and_time < Time.now
  end

  def today?
    combined_date_and_time.today?
  end

  # Is this workshop happening imminently?
  def imminent?
    future? && (3.hours.from_now > combined_date_and_time)
  end

  # Is this event in the future?
  def future?
    combined_date_and_time > Time.now
  end

  def combined_date_and_time
    date_and_time.beginning_of_day + time.seconds_since_midnight
  end

  # Is there any space at this event?
  def spaces?
    coach_spaces? || student_spaces?
  end

  # Is there space for coaches at this event?
  def coach_spaces?
    return host.coach_spots > attending_coaches.length if has_host?
    false
  end

  # Is there space for students at this event?
  def student_spaces?
    return host.seats > attending_students.length if has_host?
    false
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
    raise ArgumentError, "Person should be a Member" unless person.is_a? Member
    WaitingList.students(self).include?(person) || WaitingList.coaches(self).include?(person)
  end

  def to_s
    "Workshop"
  end

  # Which Members are organising this meeting?
  def organisers
    permissions.find_by_name("organiser").members rescue chapter.organisers
  end

  def location
    host.address.city rescue ""
  end

  def self.policy_class
    WorkshopPolicy
  end

end
