class AttendanceWarning < ActiveRecord::Base
  belongs_to :member
  belongs_to :issued_by, class_name: 'Member', foreign_key: 'sent_by_id', inverse_of: false

  scope :last_six_months, -> { where(created_at: 6.months.ago...Time.zone.now) }

  before_save :send_email

  private

  def send_email
    MemberMailer.attendance_warning(member, member.email).deliver_now
  end
end
