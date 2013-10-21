class MembersController < ApplicationController
  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)

    if @member.save
      redirect_to root_path, notice: "Thanks for signing up #{@member.name}!"
    else
      render "new"
    end
  end

  def unsubscribe
    @member = Member.find(params[:id])
    @member.update_attribute(:unsubscribed, true)

    redirect_to root_path, notice: "You have been unsubscribed succesfully"
  end

  private
  def member_params
    params.require(:member).permit(:name, :surname, :email, :twitter, :about_you)
  end
end
