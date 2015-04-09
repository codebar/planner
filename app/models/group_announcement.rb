class GroupAnnouncement < ActiveRecord::Base
  belongs_to :announcement
  belongs_to :group
end
