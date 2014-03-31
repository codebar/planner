class CoursesController < ApplicationController

  def show
    @course = Course.find_by_slug(params[:id])
  end
end

