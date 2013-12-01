class Feedback < ActiveRecord::Base
  belongs_to :tutorial
  belongs_to :coach
end
