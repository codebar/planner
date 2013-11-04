class SessionInvitation < ActiveRecord::Base

  include InvitationConcerns

  belongs_to :sessions

  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions ] }

  private

  def email
    SessionInvitationMailer.invite_student(self.sessions, self.member, self).deliver
  end

end
