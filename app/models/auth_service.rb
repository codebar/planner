class AuthService < ActiveRecord::Base
  belongs_to :member
  validates :uid, uniqueness: { constraint: :provider }
end
