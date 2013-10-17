class MembersController < ApplicationController
  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)

    if @member.save
      redirect_to root_path
    else
      render "new"
    end
  end

  private
  def member_params
    params.require(:member).permit(:name, :surname, :email, :twitter, :about_you)
  end
end
