class SkillsController < ApplicationController
  def show
    @skill = params[:id]
    @coaches = Member.with_skill(params[:id])
  end
end
