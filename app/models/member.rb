class Member < ActiveRecord::Base

  validates :name, :surname, :email, :about_you, presence: true

end
