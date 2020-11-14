class AuthService < ApplicationRecord
  belongs_to :member
  validates :uid, uniqueness: { constraint: :provider }
end
