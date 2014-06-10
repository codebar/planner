class Group < ActiveRecord::Base
  belongs_to :chapter

  validates :name, :chapter_id, presence: true
end
