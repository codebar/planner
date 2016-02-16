class Admin::InvitationsController < Admin::ApplicationController
  include  Admin::WorkshopConcerns

  def update
    set_workshop
    authorize @workshop

    set_invitation

    if params.has_key?(:attending)
      attending = params[:attending]

      if attending.eql?("true")
        @invitation.update_attribute(:attending, true)

        waiting_listed = WaitingList.where(invitation: @invitation).first
        waiting_listed.delete if waiting_listed

        SessionInvitationMailer.attending(@workshop, @invitation.member, @invitation).deliver_now if @workshop.future?

        message = "You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."
      else
        @invitation.update_attribute(:attending, false)

        message = "You have removed #{@invitation.member.full_name} from the workshop."
      end
    elsif params.has_key?(:attended)
      @invitation.update_attribute(:attended, true)

      message = "You have verified #{@invitation.member.full_name}'s attendace."
    end

    if request.xhr?
      @workshop = WorkshopPresenter.new(@workshop)
      set_admin_workshop_data

      render partial: 'admin/workshops/invitation_management'
    else
      redirect_to :back, notice: message
    end
  end

  private

  def set_invitation
    @invitation = @workshop.invitations.find_by_token(invitation_id)
  end

  def invitation_id
    params.has_key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
