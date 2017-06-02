class CoachesController < ApplicationController
  def index
  end

  def show
  end

  helper_method :chapters, :chapter, :coaches

  private
  def chapters
    @chapters ||= Chapter.order(:name)
  end

  def chapter
    @chapter ||= chapters.find_by!(slug: params[:chapter_slug])
  end

  def coaches
    @coaches ||= chapter.coaches_by_attended_sessions
  end
end
