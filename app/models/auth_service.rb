class AuthService < ApplicationRecord
  belongs_to :member, optional: true
  validates :uid, uniqueness: { constraint: :provider }
end
