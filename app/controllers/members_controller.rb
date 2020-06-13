class MembersController < ApplicationController
  include MemberConcerns

  before_action :set_member, only: %i[edit step2 profile update]
  before_action :authenticate_member!, only: %i[edit step2 profile]
  before_action :suppress_notices, only: %i[step2]

  autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'

  def new
    @page_title = 'Sign up'
  end

  def edit; end

  def step2
    @type = cookies[:member_type]
    @coach_groups = Group.coaches
    @student_groups = Group.students
  end

  def profile
    render :show
  end

  def update
    if @member.update(member_params)
      notice = 'Your details have been updated.'
      redirect_to profile_path, notice: notice
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

  def token
    params[:token]
  end
end
