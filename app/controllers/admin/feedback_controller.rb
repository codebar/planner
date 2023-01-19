class Admin::FeedbackController < SuperAdmin::ApplicationController
  def index
    @feedback = Feedback.includes(:coach, :tutorial)
                        .order('created_at desc')
                        .paginate(page: page)
  end

  private

  def page
    p = params.permit(:page)[:page].to_i
    p > 1 ? p : 1
  end
end
