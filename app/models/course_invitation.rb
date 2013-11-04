class CourseInvitation < ActiveRecord::Base

  include InvitationConcerns

  belongs_to :course
  belongs_to :member

  validates :course, :member, presence: true
  validates :member_id, uniqueness: { scope: [:course ] }

  private

  def email
    CourseInvitationMailer.invite_student(self.course, self.member, self).deliver
  end

end
