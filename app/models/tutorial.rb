class Tutorial < ActiveRecord::Base
  belongs_to :sessions

  validates :title, presence: true

  def self.all_titles
    all.map(&:title)
  end
end
