require 'services/ticket'

class EventsController < ApplicationController
  before_action :require_login, only: %i[student coach]

  def index
    redirect_to upcoming_events_path
  end

  def upcoming
    latest = latest_model_updated
    fresh_when(latest, etag: latest)
    # fresh_when renders a 304 without halting; skip the pipeline on top of it
    # (mirrors workshops#show).
    return if performed?

    @events, @pagy = EventsFeedQuery.call(upcoming: true, page: requested_page, request:)
  end

  def past
    latest = latest_model_updated
    fresh_when(latest, etag: latest)
    return if performed?

    key = past_page_cache_key(latest)
    @past_events_page_html = read_fragment(key)
    # A hit skips the COUNT, eager loads, decoration and render; the view
    # outputs the stored page. Deletions do not bump MAX(updated_at), so the
    # key alone cannot see them — the short expiry bounds that staleness.
    return if @past_events_page_html

    @past_events, @pagy = EventsFeedQuery.call(upcoming: false, page: requested_page, request:)
    # Only mint a key for a page that exists: bogus page numbers would
    # otherwise flood the cache store with garbage keys, and Solid Cache
    # evicts oldest entries globally when over max_size.
    @past_events_cache_key = key if @pagy.nil? || requested_page <= @pagy.pages
  end

  def show
    event = Event.find_by!(slug: params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

    return unless logged_in?

    invitation = Invitation.find_by(member: current_user, event:, attending: true)
    redirect_to event_invitation_path(@event, invitation) if invitation
  end

  def student
    find_invitation_and_redirect_to_event('Student')
  end

  def coach
    find_invitation_and_redirect_to_event('Coach')
  end

  def rsvp
    set_event
    return head :forbidden unless @event.rsvp_available?

    ticket = Services::Ticket.new(request, params)
    member = Member.find_by(email: ticket.email)
    invitation = find_or_create_invitation(@event, member, 'Student')

    invitation.update(attending: true)
    head :ok
  end

  private

  def requested_page
    # Clamp to >= 1 (mirrors Pagy's own resolve_page); .to_s also handles array params
    [1, params[:page].to_s.to_i].max
  end

  def past_page_cache_key(latest)
    # .to_f: a raw Time in a cache key is stringified with subsecond precision
    # that differs between the write and the read (see sitemaps/show.xml.builder).
    [:events_past_page, I18n.locale, requested_page, latest.to_f]
  end

  def latest_model_updated
    sql = <<~SQL.squish
      SELECT MAX(latest) FROM (
        SELECT MAX(updated_at) AS latest FROM "workshops"
        UNION ALL SELECT MAX(updated_at) FROM "meetings"
        UNION ALL SELECT MAX(updated_at) FROM "events"
        UNION ALL SELECT MAX(updated_at) FROM "members"
      ) t
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def find_invitation_and_redirect_to_event(role)
    set_event
    redirect_to event_invitation_path(@event, find_or_create_invitation(@event, current_user, role))
  end

  def find_or_create_invitation(event, member, role)
    # Identity is event + member, matching InvitationManager; the member's
    # role choice wins, so an existing invitation with the other role is updated.
    invitation = Invitation.find_or_create_by!(event:, member:) { |record| record.role = role }
    invitation.update!(role:) unless invitation.role.eql?(role)
    invitation
  rescue ActiveRecord::RecordNotUnique
    Invitation.find_by(event:, member:)
  end

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end
end
