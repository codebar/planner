class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  def update
    set_and_decorate_workshop
    authorize @workshop

    set_invitation

    if params.key?(:attending)
      attending = params[:attending]

      if attending.eql?('true')
        @invitation.update(attending: true, rsvp_time: Time.zone.now, automated_rsvp: true)
        @workshop.send_attending_email(@invitation) if @workshop.future?

        message = "You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."
      else
        @invitation.update_attribute(:attending, false)

        message = "You have removed #{@invitation.member.full_name} from the workshop."
      end
      waiting_listed = WaitingList.find_by(invitation: @invitation)
      waiting_listed&.destroy

    elsif params.key?(:attended)
      @invitation.update_attribute(:attended, true)

      message = "You have verified #{@invitation.member.full_name}'s attendace."
    end

    if request.xhr?
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
