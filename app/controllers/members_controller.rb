class MembersController < ApplicationController
  before_action :authenticate_member!, only: %i[edit show step1 step2 profile]
  autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'

  def new
    @page_title = 'Sign up'
  end

  def edit
    @member = current_user
  end

  def step1
    accept_terms

    @member = current_user
    @suppress_notices = true
    flash[notice] = 'Thanks for signing up. Please fill in your details to complete the registration process.'
    return unless request.post? || request.put?

    if @member.update(member_params)
      return redirect_to step2_member_path
    end
  end

  def step2
    @type = cookies[:member_type]
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

    if @member.update(member_params)
      notice = 'Your details have been updated.'
      return redirect_to profile_path, notice: notice
    else
      render 'edit'
    end
  end

  def unsubscribe
    require 'verifier'
    member = Verifier.new(token: token).verify(Member)

    session[:member_id] = member.id

    authenticate_member!

    redirect_to subscriptions_path
  rescue
    redirect_to root_path, notice: 'Your token is invalid. '
  end

  private

  def member_params
    params.require(:member).permit(
      :pronouns, :name, :surname, :email, :mobile, :twitter, :about_you, :skill_list
    )
  end

  def token
    params[:token]
  end
end
