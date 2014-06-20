class MembersController < ApplicationController
  before_action :logged_in?, only: [:edit, :show]

  def new
    @page_title = "Sign up"
  end

  def edit
    @groups = Group.all
    @member = current_user
  end

  def profile
    @member = current_user

    render :show
  end

  def update
    @member = current_user

    if @member.update_attributes(member_params)
      redirect_to :back, notice: "Your details have been updated"
    else
      render "edit"
    end
  end

  def unsubscribe
    @member = Member.find(params[:id])
    @member.update_attribute(:unsubscribed, true)

    redirect_to root_path, notice: "You have been unsubscribed succesfully"
  end

  private

  def member_params
    params.require(:member).permit(:name, :surname, :email, :mobile, :twitter, :about_you)
  end

end
