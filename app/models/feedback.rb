class Feedback < ApplicationRecord
  self.per_page = 25
  belongs_to :tutorial
  belongs_to :coach, class_name: 'Member'
  belongs_to :workshop
  has_one :chapter, through: :workshop

  validates :rating, inclusion: { in: 1..5, message: "can't be blank" }
  validates :tutorial, presence: true

  def self.submit_feedback(params, token)
    return false unless feedback_request = FeedbackRequest.find_by(token: token)

    feedback = Feedback.new(params)
    feedback.workshop = feedback_request.workshop

    if feedback.valid? && !feedback_request.submited
      feedback_request.update(submited: true)
      feedback.save
    else
      false
    end
  end
end
