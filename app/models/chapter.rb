class Chapter < ActiveRecord::Base
  validates :name, uniqueness: true
end
