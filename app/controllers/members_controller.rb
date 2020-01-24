class MembersController < ApplicationController
  include MailingListConcerns

  before_action :authenticate_member!, only: %i[edit show step1 step2 profile]
  before_action :suppress_notices, only: %i[step1 step2]
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
    flash[notice] = I18n.t('notifications.signing_up')
    @member.newsletter ||= true

    return unless request.post? || request.put?

    if @member.update(member_params)
      member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
      return redirect_to step2_member_path
    end
  end

  def step2
    @type = cookies[:member_type]
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
      :pronouns, :name, :surname, :email, :mobile, :twitter, :about_you, :skill_list, :newsletter
    )
  end

  def token
    params[:token]
  end

  def suppress_notices
    @suppress_notices = true
  end
end
