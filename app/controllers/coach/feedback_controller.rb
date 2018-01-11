class Coach::FeedbackController < Coach::ApplicationController
  def index
    @feedback = Feedback.order('created_at desc')
  end
end
