class Member < ActiveRecord::Base
  rolify role_cname: 'Permission', role_table_name: :permission, role_join_table_name: :members_permissions

  has_many :session_invitations
  has_many :auth_services
  has_many :feedbacks, foreign_key: :coach_id
  has_many :jobs, foreign_key: :created_by_id
  has_many :subscriptions
  has_many :groups, through: :subscriptions

  validates :auth_services, presence: true
  validates :name, :surname, :email, :about_you, presence: true, if: :can_log_in?
  validates_uniqueness_of :email

  scope :subscribers, -> { joins(:subscriptions).order('created_at desc').uniq }

  attr_accessor :attendance

  def full_name
    [name, surname].join " "
  end

  # Is this user a student?
  def student?
    groups.students.count > 0
  end

  # Is this user a coach?
  def coach?
    groups.coaches.count > 0
  end

  # Has this user ever attended a Codebar session?
  def newbie?
    (attended_sessions.count == 0) || (attended_sessions.count == 1 && attended_sessions.first.today?)
  end

  def received_welcome_for?(subscription)
    case subscription.try(:group).try(:name)
      when "Students"
        received_student_welcome_email
      when "Coaches"
        received_coach_welcome_email
      else
        true
    end
  end

  def avatar size=100
    "http://gravatar.com/avatar/#{md5_email}?s=#{size}"
  end

  def attended_sessions
    session_invitations.attended.map(&:sessions)
  end

  def requires_additional_details?
    can_log_in? && !valid?
  end

  def verified?
    session_invitations.exists?(role: "Coach", attended: true)
  end

  private

  def md5_email
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
