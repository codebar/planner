class Admin::FeedbackController < SuperAdmin::ApplicationController
  def index
    @feedback = Feedback.includes(:coach, :tutorial)
                        .order('created_at desc')
                        .paginate(page: page)
  end

  private

  def page
    params.permit(:page)[:page]
  end
end
