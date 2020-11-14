class GroupAnnouncement < ApplicationRecord
  belongs_to :announcement
  belongs_to :group
end
