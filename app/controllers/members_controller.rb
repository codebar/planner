class MembersController < ApplicationController
  before_action :authenticate_member!, only: [:edit, :show, :step1, :step2]

  def new
    @page_title = "Sign up"
  end

  def edit
    @groups = Group.all
    @member = current_user
  end

  # Show the first step of the new user flow. A custom edit form for the user.
  def step1
    @suppress_notices = true
    @member = current_user

    if request.post? or request.put?
      if @member.update_attributes(member_params)
        redirect_to step2_member_path and return
      end
    end
  end


  # Second step of the new user flow. Choose mailing lists.
  def step2
    @suppress_notices = true
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
      redirect_to(:back, notice: notice) and return
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
