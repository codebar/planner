class Admin::EventCheckInsController < Admin::ApplicationController
  before_action :set_event
  before_action :authorize_event

  def create
    invitation = find_invitation
    invitation.update!(verified: true, verified_by_id: current_user.id, source: Invitation::SOURCE_ADMIN)
    record_verification!(invitation)

    respond_to_check_in(invitation)
  end

  def destroy
    invitation = find_invitation
    invitation.update!(verified: false, verified_by_id: nil)

    respond_to_undo(invitation)
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  def authorize_event
    authorize @event, :show?, policy_class: EventPolicy
  end

  def find_invitation
    @event.invitations.accepted.find(params[:invitation_id])
  end

  def record_verification!(invitation)
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.verified',
                                  trackable: invitation, recipient: invitation.member)
    EventInvitationMailer.attending(@event, invitation.member, invitation).deliver_now
  end

  def respond_to_check_in(invitation)
    return redirect_back(fallback_location: admin_event_path(@event)) unless request.xhr?

    pairings = @event.pairings.with_members
    pairing = pairings.find { |p| p.pairing_invitations.any? { |pi| pi.invitation_id == invitation.id } }
    render json: check_in_payload(invitation, pairing, pairings)
  end

  def respond_to_undo(invitation)
    return redirect_back(fallback_location: admin_event_path(@event)) unless request.xhr?

    pairings = @event.pairings.with_members
    render json: {
      invitation_id: invitation.id,
      board_html: render_board_html(pairings),
      expected_counts:
    }
  end

  def check_in_payload(invitation, pairing, pairings)
    partners = pairing ? partner_names_for(pairing, invitation) : []
    {
      invitation_id: invitation.id,
      pairing_id: pairing&.id,
      partner_names: partners,
      role: invitation.role,
      board_html: render_board_html(pairings),
      expected_counts:
    }
  end

  def partner_names_for(pairing, invitation)
    pairing.pairing_invitations
           .map(&:invitation)
           .reject { |other| other.id == invitation.id }
           .map { |other| other.member.full_name }
  end

  def render_board_html(pairings)
    render_to_string(partial: 'admin/events/pairing', locals: { event: @event, pairings: },
                     layout: false, formats: [:html])
  end

  def expected_counts
    { students: @event.expected_students.count, coaches: @event.expected_coaches.count }
  end
end
