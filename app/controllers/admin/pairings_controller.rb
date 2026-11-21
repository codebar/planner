class Admin::PairingsController < Admin::ApplicationController
  before_action :set_event
  before_action :authorize_event

  def index
    return redirect_to(admin_event_path(@event)) unless request.xhr?

    pairings = @event.synced_pairings
    response.headers['Cache-Control'] = 'no-cache'
    return unless stale?(etag: @event.pairing_board_etag(pairings))

    render json: sync_payload(pairings)
  end

  def create
    invitation = verified_invitations.find(params[:invitation_id])
    pairing = @event.pairings.find(params[:pairing_id])

    Pairing.add!(invitation, pairing)
    respond_with_board
  end

  def destroy
    invitation = verified_invitations.find(params[:invitation_id])

    Pairing.pull_out!(invitation)
    respond_with_board
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  def authorize_event
    authorize @event, :show?, policy_class: EventPolicy
  end

  def verified_invitations
    @event.invitations.accepted.verified
  end

  def sync_payload(pairings)
    board_html = render_to_string(partial: 'admin/events/pairing', locals: { event: @event, pairings: },
                                  layout: false, formats: [:html])
    {
      board_html:,
      checked_in_ids: verified_invitations.pluck(:id),
      expected_counts: {
        students: @event.expected_students.count,
        coaches: @event.expected_coaches.count
      }
    }
  end

  def respond_with_board
    if request.xhr?
      pairings = @event.pairings.with_members
      render partial: 'admin/events/pairing', locals: { event: @event, pairings: }, layout: false
    else
      redirect_to admin_event_path(@event)
    end
  end
end
