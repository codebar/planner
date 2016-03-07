class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: [:show, :rsvp]

  def show
    @workshop = WorkshopPresenter.new(@workshop)
    @host_address = AddressDecorator.decorate(@workshop.host.address) if @workshop.has_host?
  end

  def rsvp
    redirect_to :back, notice: "This workshop is not open for registrations" unless @workshop.invitable

    if role_params.nil?
      @invitation = SessionInvitation.where(workshop: @workshop, member: current_user, attending: true).first
    else
      @invitation = SessionInvitation.where(workshop: @workshop, member: current_user, role: role_params).first_or_create
    end

    redirect_to invitation_path(@invitation)
  end

  def add
    workshop = Workshop.find(params[:id])
    @workshop = WorkshopPresenter.new(workshop)

    if @workshop.invitable
      waiting_listed = false

      case params[:role]
        when "student"
          @invitation = SessionInvitation.where(workshop: workshop, member: current_user, role: "Student").first_or_create
          if @workshop.student_spaces?
            @invitation.update_attribute(:attending, true)
          else
            WaitingList.add(@invitation, true)
            waiting_listed = true
          end
        when "coach"
          @invitation = SessionInvitation.where(workshop: workshop, member: current_user, role: "Coach").first_or_create
          if @workshop.coach_spaces?
            @invitation.update_attribute(:attending, true)
          else
            WaitingList.add(@invitation, true)
            waiting_listed = true
          end
        else
          redirect_to workshop_path(@workshop) and return
      end

      if waiting_listed
        redirect_to :waitlisted_workshop and return
      else
        redirect_to :added_workshop and return
      end
    else
      redirect_to workshop_path(@workshop), notice: "Registrations for this event are not available."
    end
  end


  def remove
    workshop = Workshop.find(params[:id])
    SessionInvitation.where(workshop: workshop, member: current_user).each do |i|
      i.update_attribute(:attending, false)
      waiting_list = WaitingList.find_by_invitation_id(i.id)
      waiting_list.delete if waiting_list
    end
    redirect_to removed_workshop_path(workshop) and return
  end


  # Show a "You've been removed from this event" page.
  def removed
    @workshop = WorkshopPresenter.new(Workshop.find(params[:id]))
  end

  # Show a "You've been added to this event" page.
  def added
    @workshop = Workshop.find(params[:id])
    @coach = SessionInvitation.where(workshop: @workshop, member: current_user, attending: true, role: "Coach").any?
  end

  # Show a "You've been waitlisted for this event" page.
  def waitlisted
    @workshop = Workshop.find(params[:id])
    @coach = WaitingList.coaches(@workshop).include? current_user
  end

  private

   def set_workshop
    @workshop = Workshop.find(params[:id])
   end

   def role_params
     params[:role]
   end
end
