class SkillsController < ApplicationController
  def show
    @skill = params[:id]
    @coaches = Member.with_skill(params[:id]).paginate(page: page)
  end

  private
  def page
    params.permit(:page)[:page]
  end
end
