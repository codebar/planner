class Member < ActiveRecord::Base

  validates :name, :surname, :email, :about_you, presence: true
  validates_uniqueness_of :email

end
