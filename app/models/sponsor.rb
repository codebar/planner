class Sponsor < ActiveRecord::Base

  validates :name, :description, presence: true
end