class CourseTutor < ApplicationRecord
  belongs_to :tutor, class_name: 'Member'
  belongs_to :course
end
