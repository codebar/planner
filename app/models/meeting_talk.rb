class MeetingTalk < ActiveRecord::Base
  belongs_to :speaker, class_name: 'Member'
  belongs_to :meeting

  validates :title, :abstract, :speaker, :meeting, presence: true

  default_scope -> { order('title asc') }
end
