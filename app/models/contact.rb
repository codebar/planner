class Contact < ActiveRecord::Base

  validates :name, :surname, :email, presence: true
end
