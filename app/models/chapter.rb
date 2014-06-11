class Chapter < ActiveRecord::Base
  validates :name, uniqueness: true

  has_many :sessions
end
