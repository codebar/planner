class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns
  include WaitlistPromotionConcerns

  def update
    set_and_decorate_workshop
    authorize @workshop
    set_invitation

    result = update_attendance(attending: params[:attending], attended: params[:attended])

    if request.xhr?
      if params[:attended].present?
        inject_attendance_flags([@invitation])
        render partial: 'admin/workshop/attendance_row',
               locals: { invitation: InvitationPresenter.new(@invitation), workshop: @workshop }
      else
        set_admin_workshop_data
        render partial: 'admin/workshops/invitation_management', locals: { feedback: result }
      end
    else
      redirect_back fallback_location: root_path, notice: (result[:message] if result.is_a?(Hash))
    end
  end

  private

  def update_attendance(attending:, attended:)
    return update_to_attended if attended.to_s == 'true'
    return update_to_unattended if attended.to_s == 'false'

    waiting_listed = WaitingList.find_by(invitation: @invitation)
    result = attending.eql?('true') ? update_to_attending : update_to_not_attending(waiting_listed:)

    waiting_listed&.destroy unless result[:error]

    result
  end

  def update_to_attended
    return unless @invitation.update(
      attended: true,
      checked_in_at: @invitation.checked_in_at || Time.zone.now,
      source: Invitation::SOURCE_ADMIN
    )

    MemberActivityRecorder.record(actor: current_user, key: 'invitation.rsvp_override',
                                  trackable: @invitation, recipient: @invitation.member)
    WorkingGroups::Service.for(@workshop).safe_on_check_in(@invitation)
  end

  def update_to_unattended
    @invitation.update(attended: nil, checked_in_at: nil)
    WorkingGroups::Service.for(@workshop).safe_on_check_out(@invitation)
  end

  def update_to_attending
    update_successful = @invitation.update(
      attending: true,
      rsvp_time: Time.zone.now,
      automated_rsvp: true,
      last_overridden_by_id: current_user.id,
      source: Invitation::SOURCE_ADMIN
    )

    if update_successful
      MemberActivityRecorder.record(actor: current_user, key: 'invitation.rsvp_override',
                                    trackable: @invitation, recipient: @invitation.member)
    end

    {
      message: update_successful ? attending_successful : attending_failed,
      error: !update_successful
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

  def update_to_not_attending(waiting_listed: nil)
    freed_seat = release_seat(last_overridden_by_id: current_user.id)
    WorkingGroups::Service.for(@workshop).safe_on_check_out(@invitation)
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.rsvp_override',
                                  trackable: @invitation, recipient: @invitation.member)

    promote_next_waitlist_member if freed_seat && @workshop.future?

    target = !freed_seat && waiting_listed ? 'the waiting list' : 'the workshop'
    {
      message: "You have removed #{@invitation.member.full_name} from #{target}.",
      error: false
    }
  end

  def set_invitation
    @invitation = @workshop.invitations.find_by!(token: invitation_id)
  end

  def invitation_id
    params.key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
