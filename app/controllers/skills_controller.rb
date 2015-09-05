class SkillsController < ApplicationController
  def show
    @skill = params[:id]
    @coaches = Member.tagged_with(params[:id])
  end
end