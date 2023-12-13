class Admin::FeedbackController < SuperAdmin::ApplicationController
  def index
    @feedback = Feedback.includes(:coach, :tutorial)
                        .order('created_at desc')
  end
end
