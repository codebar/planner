# frozen_string_literal: true

# Single funnel for member-activity rows on the public_activity `activities` table.
# Explicit call sites only — no model callbacks — so nothing is double-logged.
# Recording is observability: persistence failures are logged, never raised.
class MemberActivityRecorder
  # Key vocabulary in use; extend when adding sites. New keys classify as :active in the strip.
  KEYS = %w[
    member.login
    member.logout
    member.checked_in
    member_note.created
    member.banned
    profile.updated
    toc.accepted
    auth_service.removed
    subscription.created
    subscription.removed
    subscription.admin_updated
    mailing_list.subscribe
    mailing_list.unsubscribe
    event_invitation.rsvp
    event_invitation.rejected
    meeting_invitation.rsvp
    meeting_invitation.cancelled
    workshop_invitation.rsvp
    workshop_invitation.rejected
    waiting_list.joined
    waiting_list.left
    organiser_role.granted
    organiser_role.revoked
    invitation.send_batch
    invitation.rsvp_override
    invitation.verified
    workshop.created
    meeting_invitation.created
    meeting_invitation.updated
  ].freeze

  def self.record(actor:, key:, trackable: nil, recipient: nil)
    Rails.logger.warn("MemberActivityRecorder: unregistered key '#{key}'") unless KEYS.include?(key)
    trackable ||= actor
    PublicActivity::Activity.create!(owner: actor, key:, trackable:, recipient:)
  rescue StandardError => e
    Rails.logger.warn("MemberActivityRecorder failed (#{key}): #{e.class}: #{e.message}")
  end
end
