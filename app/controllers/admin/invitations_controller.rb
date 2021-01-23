class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  def update
    set_and_decorate_workshop
    authorize @workshop

    set_invitation

    message, error = update_attendance(params.slice(:attending, :attended))

    unless error
      waiting_listed = WaitingList.find_by(invitation: @invitation)
      waiting_listed&.destroy
    end

    if request.xhr?
      set_admin_workshop_data

      render partial: 'admin/workshops/invitation_management'
    else
      redirect_to :back, notice: message
    end
  end

  private

  def update_attendance(attending:, attended:)
    return update_to_attended if attended

    if attending.eql? 'true'
      update_to_attending
    else
      update_to_not_attending
    end
  end

  def update_to_attended
    @invitation.update_attribute(:attended, true)

    ["You have verified #{@invitation.member.full_name}'s attendace."]
  end

  def update_to_attending
    if @invitation.update(attending: true, rsvp_time: Time.zone.now, automated_rsvp: true)
      @workshop.send_attending_email(@invitation) if @workshop.future?

      ["You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."]
    else
      error_message = @invitation.errors.full_messages.to_sentence

      ["Error adding #{@invitation.member.full_name} as a #{@invitation.role}. #{error_message}.", false]
    end
  end

  def update_to_not_attending
    @invitation.update_attribute(:attending, false)

    ["You have removed #{@invitation.member.full_name} from the workshop."]
  end

  def set_invitation
    @invitation = @workshop.invitations.find_by(token: invitation_id)
  end

  def invitation_id
    params.key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
