class Coach::FeedbackController < Coach::ApplicationController
  def index
    @feedback = Feedback.includes(:coach)
                        .includes(:tutorial)
                        .order('created_at desc')
                        .paginate(page: page)
  end

  private

  def page
    params.permit(:page)[:page]
  end
end
