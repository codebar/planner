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

  def has_host?
    SponsorSession.exists?(host: true, sessions: self)
  end

  def has_valid_host?
    has_host? and host.address.present?
  end

  # Is this event in the past?
  def past?
    date_and_time < Time.now
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

  def to_s
    "Workshop"
  end

  def location
    host.address.city rescue ""
  end

  def self.policy_class
    WorkshopPolicy
  end

  def date_and_time
    read_attribute(:date_and_time).change(hour: time.hour, minute: time.min)
  end

  def date_and_time=(date_and_time)
    write_attribute(:date_and_time, date_and_time.to_date)
    write_attribute(:time, date_and_time.to_time)
  end
end
