class MembersController < ApplicationController
  before_action :logged_in?, only: [:edit, :show, :step1, :step2]

  def new
    @page_title = "Sign up"
  end

  def edit
    @groups = Group.all
    @member = current_user
  end

  # Show the first step of the new user flow. A custom edit form for the user.
  def step1
    @member = current_user
  end

  # Second step of the new user flow. Choose mailing lists.
  def step2
    @member = current_user
    @coach_groups = Group.coaches
    @student_groups = Group.students
  end

  def profile
    @member = current_user

    render :show
  end

  def update
    @member = current_user

    if @member.update_attributes(member_params)
      notice = "Your details have been updated"
      if params[:next_page]
        redirect_to(params[:next_page], notice: notice) and return
      else
        redirect_to(:back, notice: notice) and return
      end
    else
      @groups = Group.all
      render "edit"
    end
  end

  def unsubscribe
    require 'verifier'
    member = Verifier.new(token: token).verify(Member)

    session[:member_id] = member.id

    authenticate_member!

    redirect_to subscriptions_path
  rescue
    redirect_to root_path, notice: "Your token is invalid. "
  end

  private

  def member_params
    params.require(:member).permit(:name, :surname, :email, :mobile, :twitter, :about_you)
  end

  def token
    params[:token]
  end

end
