class Sponsor < ActiveRecord::Base
  has_one :address
  belongs_to :sessions

  validates :name, :description, :address, presence: true
end