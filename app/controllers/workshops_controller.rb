class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: %i[show rsvp]

  def show
    @workshop = WorkshopPresenter.new(@workshop)
    @host_address = AddressDecorator.decorate(@workshop.host.address) if @workshop.has_host?
  end

  def rsvp
    redirect_to :back, notice: 'This workshop is not open for registrations' unless @workshop.invitable_yet?

    if role_params.nil?
      @invitation = SessionInvitation.where(workshop: @workshop, member: current_user, attending: true).first
    else
      return redirect_to :back, notice: 'You have already RSVPd or joined the waitlist for this workshop.' if @workshop.attendee?(current_user) or @workshop.waitlisted?(current_user)

      @invitation = SessionInvitation.where(workshop: @workshop, member: current_user, role: role_params).first_or_create
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
