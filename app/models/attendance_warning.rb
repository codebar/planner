class AttendanceWarning < ApplicationRecord
  belongs_to :member
  belongs_to :added_by, class_name: 'Member'
end
