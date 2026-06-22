class AttendanceWarning < ApplicationRecord
  belongs_to :member
  belongs_to :issued_by, class_name: 'Member', foreign_key: 'sent_by_id', inverse_of: false, optional: true

  scope :last_six_months, -> { where(created_at: 6.months.ago...Time.zone.now) }
end
