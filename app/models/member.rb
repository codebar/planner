class Member < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :name, :surname, :email, :about_you, presence: true
  validates_uniqueness_of :email

end
