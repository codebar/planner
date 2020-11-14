class Role < ApplicationRecord
  has_and_belongs_to_many :members

  scope :no_admins, -> { where.not(name: 'Admin') }
end
