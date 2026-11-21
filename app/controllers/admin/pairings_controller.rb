class Admin::PairingsController < Admin::ApplicationController
  before_action :set_event
  before_action :authorize_event

  def index
    @pairings = @event.synced_pairings
    @expected_count = @event.expected_students.count + @event.expected_coaches.count

    if request.xhr?
      response.headers['Cache-Control'] = 'no-cache'
      return unless stale?(etag: @event.pairing_board_etag(@pairings))

      render partial: 'admin/events/pairing', locals: { event: @event, pairings: @pairings }, layout: false
    end
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

  def respond_with_board
    if request.xhr?
      pairings = @event.pairings.with_members
      render partial: 'admin/events/pairing', locals: { event: @event, pairings: }, layout: false
    else
      redirect_to admin_event_path(@event)
    end
  end
end
