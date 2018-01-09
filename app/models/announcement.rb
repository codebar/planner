class Announcement < ActiveRecord::Base
  has_many :group_announcements
  has_many :groups, through: :group_announcements

  belongs_to :created_by, class_name: 'Member'

  scope :active, -> { where('expires_at > ?', Date.current) }
end
