class Member < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_many :session_invitations

  validates :name, :surname, :email, :about_you, presence: true
  validates_uniqueness_of :email

  scope :students, -> { joins(:roles).where(:roles => { :name => 'Student' }) }
  scope :coaches, -> { joins(:roles).where(:roles => { :name => 'Coach' }) }

  attr_accessor :attendance

  def full_name
    [name, surname].join " "
  end

  def avatar size=100
    "http://gravatar.com/avatar/#{md5_email}?s=#{size}"
  end

  def attended_sessions
    session_invitations.attended.map(&:sessions)
  end

  private

  def md5_email
    Digest::MD5.hexdigest(email.strip.downcase)
  end

end
