class CourseTutor < ActiveRecord::Base
  belongs_to :tutor, class_name: 'Member'
  belongs_to :course
end
