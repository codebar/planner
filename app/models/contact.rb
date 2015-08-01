class Contact < ActiveRecord::Base
  has_many :member_contacts
  has_many :sponsors, through: :member_contacts
end
