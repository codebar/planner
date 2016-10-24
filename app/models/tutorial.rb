class Tutorial < ActiveRecord::Base
  belongs_to :workshop

  validates :title, presence: true
  default_scope -> { order(:created_at) }

  def self.all_titles
    all.map(&:title)
  end
end
