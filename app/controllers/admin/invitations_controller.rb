class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  def update
    set_and_decorate_workshop
    authorize @workshop
    set_invitation

    message = update_attendance(attending: params[:attending], attended: params[:attended])

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

    result = attending.eql?('true') ? update_to_attending : update_to_not_attending
    message, error = result.values_at(:message, :error)

    unless error
      waiting_listed = WaitingList.find_by(invitation: @invitation)
      waiting_listed&.destroy
    end

    message
  end

  def update_to_attended
    @invitation.update(attended: true)

    "You have verified #{@invitation.member.full_name}’s attendace."
  end

  def record_attending_update(&block)
    audit = Auditor::Audit.new(@invitation, :attending, current_user)
    audit.log(&block)
  end

  def update_to_attending
    # `assign_attributes` instead of `update` because we want to separate the
    # change from the save. Change the values now but only save when recording
    # activity with the public_activity gem.
    @invitation.assign_attributes(attending: true, rsvp_time: Time.zone.now, automated_rsvp: true)

    update_successful = record_attending_update { @invitation.save }

    {
      message: update_successful ? attending_successful : attending_failed,
      error: !update_successful
    }
  end

  def update_to_not_attending
    @invitation.assign_attributes(attending: false)

    record_attending_update { @invitation.save }

    {
      message: "You have removed #{@invitation.member.full_name} from the workshop.",
      error: false
    }
  end

  def attending_successful
    @workshop.send_attending_email(@invitation) if @workshop.future?

    "You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."
  end

  def attending_failed
    "Error adding #{@invitation.member.full_name} as a #{@invitation.role}. "\
      "#{@invitation.errors.full_messages.to_sentence}."
  end

  def set_invitation
    @invitation = @workshop.invitations.find_by(token: invitation_id)
  end

  def invitation_id
    params.key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
