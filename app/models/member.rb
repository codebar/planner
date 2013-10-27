class Member < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :name, :surname, :email, :about_you, presence: true
  validates_uniqueness_of :email

  scope :students, -> { joins(:roles).where(:roles => { :name => 'Student' }) }
  scope :coaches, -> { joins(:roles).where(:roles => { :name => 'Coach' }) }

end
