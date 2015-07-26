class Member < ActiveRecord::Base
  rolify role_cname: 'Permission', role_table_name: :permission, role_join_table_name: :members_permissions

  has_many :attendance_warnings
  has_many :bans
  has_many :eligibility_inquiries
  has_many :session_invitations
  has_many :invitations
  has_many :auth_services
  has_many :feedbacks, foreign_key: :coach_id
  has_many :jobs, foreign_key: :created_by_id
  has_many :subscriptions
  has_many :groups, through: :subscriptions
  has_many :member_notes
  has_many :chapters, -> { uniq }, through: :groups
  has_many :announcements, -> { uniq }, through: :groups

  validates :auth_services, presence: true
  validates :name, :surname, :email, :about_you, presence: true, if: :can_log_in?
  validates_uniqueness_of :email

  scope :subscribers, -> { joins(:subscriptions).order('created_at desc').uniq }

  attr_accessor :attendance

  def banned?
    bans.active.present?
  end

  def full_name
    [name, surname].join " "
  end

  def student?
    groups.students.count > 0
  end

  def coach?
    groups.coaches.count > 0
  end

  def received_welcome_for?(subscription)
    return received_student_welcome_email if subscription.student?
    return received_coach_welcome_email if subscription.coach?
    true
  end

  def send_eligibility_email(user)
    MemberMailer.eligibility_check(self)
    self.eligibility_inquiries.create(sent_by_id: user.id)
  end

  def send_attendance_email(user)
    MemberMailer.attendance_warning(self)
    self.attendance_warnings.create(sent_by_id: user.id)
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

  def twitter_url
    "http://twitter.com/#{twitter}"
  end

  private

  def md5_email
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
