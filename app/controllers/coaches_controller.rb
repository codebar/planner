class CoachesController < ApplicationController
  def index
  end

  def show
  end

  private
  helper_method :chapters
  def chapters
    @chapters ||= Chapter.by_name
  end

  helper_method :chapter
  def chapter
    @chapter ||= chapters.find_by!(slug: params[:chapter_slug])
  end

  helper_method :coaches
  def coaches
    @coaches ||= chapter.coaches.sort_by do |coach|
      coach.attended_sessions.count
    end.reverse
  end
end
