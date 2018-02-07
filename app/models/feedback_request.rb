class FeedbackRequest < ActiveRecord::Base
  belongs_to :member
  belongs_to :workshop

  validates :member_id, presence: true, uniqueness: { scope: [:workshop] }
  validates :workshop, presence: true
  validates :token, uniqueness: true, presence: true
  validates_inclusion_of :submited, in: [true, false]

  before_validation :set_token
  after_create :email

  private

  def set_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.where(token: random_token).exists?
    end
  end

  def email
    FeedbackRequestMailer.request_feedback(self.workshop, self.member, self).deliver_now
  end
end
