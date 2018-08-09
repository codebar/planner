class SkillsController < ApplicationController
  def show
    @coaches = Member.includes(:skills)
                     .with_skill(skill)
                     .paginate(page: page)
  end

  private

  def skill
    params.permit(:id)[:id]
  end

  def page
    params.permit(:page)[:page]
  end
end
