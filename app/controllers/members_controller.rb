class MembersController < ApplicationController
  include MailingListConcerns

  before_action :set_member, only: %i[edit step1 step2 profile update]
  before_action :authenticate_member!, only: %i[edit show step1 step2 profile]
  before_action :suppress_notices, only: %i[step1 step2]

  autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'

  def new
    @page_title = 'Sign up'
  end

  def edit; end

  def step1
    accept_terms

    flash[notice] = I18n.t('notifications.signing_up')
    @member.newsletter ||= true

    return unless request.post? || request.put?

    return unless @member.update(member_params)
    member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end

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

  def set_member
    @member = current_user
  end
end
