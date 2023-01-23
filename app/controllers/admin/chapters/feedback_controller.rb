class Admin::Chapters::FeedbackController < Admin::ApplicationController
  before_action :set_chapter, only: [:index]
  after_action :verify_authorized

  def index
    authorize(@chapter)
    @feedback = @chapter.feedbacks.includes(:tutorial)
                        .includes(:coach)
                        .order('feedbacks.created_at desc')
                        .paginate(page: page)

    render template: 'admin/feedback/index'
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def page
    p = params.permit(:page)[:page].to_i
    p > 1 ? p : 1
  end
end
