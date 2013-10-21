class Invitation < ActiveRecord::Base
  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions ] }

  belongs_to :sessions
  belongs_to :member

  after_create :email

  private

  def email
    InvitationMailer.invite(self.sessions, self.member, "token").deliver
  end
end
