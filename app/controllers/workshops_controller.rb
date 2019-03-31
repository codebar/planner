class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: %i[show rsvp]

  def show
    @workshop = WorkshopPresenter.new(@workshop)
    @host_address = AddressPresenter.new(@workshop.host.address) if @workshop.has_host?
  end

  def rsvp # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    unless @workshop.invitable_yet?
      flash[:notice] = 'This workshop is not open for registrations'
      redirect_back(fallback_location: root_path)
    end

    if role_params.nil?
      @invitation = WorkshopInvitation.find_by(workshop: @workshop, member: current_user, attending: true)
    elsif @workshop.attendee?(current_user) || @workshop.waitlisted?(current_user)
      flash[:notice] = 'You have already RSVPd or joined the waitlist for this workshop.'
      return redirect_back(fallback_location: root_path)
    else
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
