class Invitation < ActiveRecord::Base
  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions ] }
  validates :token, uniqueness: true

  belongs_to :sessions
  belongs_to :member

  before_create :set_token
  after_create :email

  scope :accepted, ->  { where(attending: true) }

  def to_param
    token
  end

  private

  def email
    InvitationMailer.invite(self.sessions, self.member, self).deliver
  end

  def set_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Invitation.where(token: random_token).exists?
    end
  end

end
