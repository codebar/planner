class Feedback < ActiveRecord::Base
  belongs_to :tutorial
  belongs_to :coach, class_name: "Member"
end
