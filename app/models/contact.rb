class Contact < ApplicationRecord
  belongs_to :sponsor, optional: true

  validates :name, :surname, :email, presence: true
  validates :email, uniqueness: { scope: :sponsor_id }

  before_create :set_token

  private

  def set_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.where(token: random_token).exists?
    end
  end
end
