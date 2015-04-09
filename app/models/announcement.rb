class Announcement < ActiveRecord::Base
  has_many :group_announcements
  has_many :groups, through: :group_announcements

  belongs_to :created_by, class: Member

  scope :active, -> { where("expires_at > ?", Date.today) }
end
