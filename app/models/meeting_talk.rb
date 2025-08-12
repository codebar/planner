class MeetingTalk < ApplicationRecord
  belongs_to :speaker, class_name: 'Member', optional: true
  belongs_to :meeting, optional: true

  validates :title, :abstract, :speaker, :meeting, presence: true

  default_scope -> { order('title asc') }
end
