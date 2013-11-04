class SessionInvitation < ActiveRecord::Base

  include InvitationConcerns

  belongs_to :sessions

  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions ] }

  def send_reminder
    SessionInvitationMailer.remind_student(self.sessions, self.member, self).deliver if attending
  end

  private

  def email
    SessionInvitationMailer.invite_student(self.sessions, self.member, self).deliver
  end

end
