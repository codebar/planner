class Sponsor < ActiveRecord::Base
  has_one :address

  validates :name, :description, :address, presence: true
end