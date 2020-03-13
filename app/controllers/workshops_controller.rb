class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: %i[show rsvp]

  def show
    @workshop = WorkshopPresenter.decorate(@workshop)

    render 'virtual_workshops/show' if @workshop.virtual?
  end

  def rsvp
    redirect_to :back, notice: t('workshops.registration_not_open') unless @workshop.invitable_yet?

    if role_params.nil?
      @invitation = find_attending_invitation(@workshop, current_user)
    else
      if user_attending_or_waitlisted?(@workshop, current_user)
        return redirect_to :back, notice: t('workshops.already_wish_to_attend')
      end

      @invitation = find_or_create_invitation(@workshop, current_user, role_params)
    end

    redirect_to invitation_path(@invitation)
  end

  private

  def set_workshop
    @workshop = Workshop.find(params[:id])
  end

  def role_params
    params[:role]
  end

  def find_attending_invitation(workshop, user)
    WorkshopInvitation.find_by(workshop: workshop, member: user, attending: true)
  end

  def find_or_create_invitation(workshop, user, role)
    WorkshopInvitation.find_or_create_by(workshop: workshop,
                                         member: user,
                                         role: role)
  end

  def user_attending_or_waitlisted?(workshop, user)
    workshop.attendee?(user) || workshop.waitlisted?(user)
  end
end
