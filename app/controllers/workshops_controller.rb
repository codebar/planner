class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: %i[show rsvp]

  def show
    @workshop = WorkshopPresenter.new(@workshop)
    @host_address = AddressPresenter.new(@workshop.host.address) if @workshop.has_host?

    render 'virtual_workshops/show' if @workshop.virtual?
  end

  def rsvp
    redirect_to :back, notice: t('workshops.registration_not_open') unless @workshop.invitable_yet?

    if role_params.nil?
      @invitation = WorkshopInvitation.find_by(workshop: @workshop, member: current_user, attending: true)
    else
      if @workshop.attendee?(current_user) || @workshop.waitlisted?(current_user)
        return redirect_to :back, notice: t('workshops.already_wish_to_attend')
      end

      @invitation = WorkshopInvitation.find_or_create_by(workshop: @workshop, member: current_user, role: role_params)
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
end
