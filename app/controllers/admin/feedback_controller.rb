class Admin::FeedbackController < Admin::ApplicationController


  def index
    @feedback = Feedback.all
  end

end
