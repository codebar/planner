class WorkshopsController < ApplicationController
  def show
    @workshop = WorkshopPresenter.new(Sessions.find(params[:id]))
  end


  # Add a user to this workshop, either to the attendees or the waiting list.
  def add
    unless logged_in?
      redirect_to "/auth/github" and return
    end
    @workshop = Sessions.find(params[:id])
    waiting_listed = false
    case params[:role]
      when "student"
        @invitation = SessionInvitation.where(sessions: @workshop, member: current_user, role: "Student").first_or_create
        if @workshop.student_spaces?
          @invitation.update_attribute(:attending, true)
        else
          WaitingList.add(@invitation, true)
          waiting_listed = true
        end
      when "coach"
        @invitation = SessionInvitation.where(sessions: @workshop, member: current_user, role: "Coach").first_or_create
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
  end


  # Remove a user from this workshop, either to the attendees or the waiting list.
  def remove
    unless logged_in?
      redirect_to "/auth/github" and return
    end
    workshop = Sessions.find(params[:id])
    invitation = SessionInvitation.where(sessions: workshop, member: current_user).first
    if invitation
      invitation.update_attribute(:attending, false)
      waiting_list = WaitingList.find_by_invitation_id(invitation.id)
      waiting_list.delete if waiting_list
    end
    redirect_to removed_workshop_path(workshop) and return
  end


  # Show a "You've been removed from this event" page.
  def removed
  end

  # Show a "You've been added to this event" page.
  def added
  end

  # Show a "You've been waitlisted for this event" page.
  def waitlisted
  end
end
