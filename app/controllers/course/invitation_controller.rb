class Course::InvitationController < ApplicationController
  before_action :set_invitation

  def show
    @course = CoursePresenter.new(@invitation.course)
    @host_address = AddressPresenter.new(@invitation.course.sponsor.address)
  end

  def accept
    if @invitation.attending.eql? true
      redirect_to root_path, notice: t('messages.already_rsvped')

    elsif has_remaining_seats?(@invitation)
      @invitation.update_attribute(:attending, true)

      redirect_to root_path, notice: t('messages.accepted_invitation',
                                       name: @invitation.member.name)
    else
      redirect_to root_path, notice: t('messages.no_available_seats')
    end
  end

  def reject
    if @invitation.attending.eql? false
      redirect_to root_path, notice: t('messages.not_attending_already')
    else
      @invitation.update_attribute(:attending, false)
      redirect_to root_path, notice: t('messages.rejected_invitation', name: @invitation.member.name)
    end
  end

  private
  def set_invitation
    @invitation = CourseInvitation.find_by(token: params[:id])
  end

  def has_remaining_seats?(invitation)
    invitation.course.seats > invitation.course.attending.length
  end
end
