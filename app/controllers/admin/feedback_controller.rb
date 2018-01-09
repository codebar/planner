class Admin::FeedbackController < Admin::ApplicationController
  def index
    @feedback = Feedback.includes(:coach, :tutorial).all
  end
end
