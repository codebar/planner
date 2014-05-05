class Job < ActiveRecord::Base
  belongs_to :created_by, class_name: "Member", foreign_key: :created_by_id

end
