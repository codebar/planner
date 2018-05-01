class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  def update
    set_workshop
    authorize @workshop

    set_invitation

    if params.key?(:attending)
      attending = params[:attending]

      if attending.eql?('true')
        @invitation.update_attribute(:attending, true)

        WorkshopInvitationMailer.attending(@workshop, @invitation.member, @invitation).deliver_now if @workshop.future?

        message = "You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."
      else
        @invitation.update_attribute(:attending, false)

        message = "You have removed #{@invitation.member.full_name} from the workshop."
      end
      waiting_listed = WaitingList.find_by(invitation: @invitation)
      waiting_listed.destroy if waiting_listed

    elsif params.key?(:attended)
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
    @invitation = @workshop.invitations.find_by(token: invitation_id)
  end

  def invitation_id
    params.key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
