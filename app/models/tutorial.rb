class Tutorial < ActiveRecord::Base
  belongs_to :sessions

  validates :title, presence: true
end
