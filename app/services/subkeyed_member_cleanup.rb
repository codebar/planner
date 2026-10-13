# frozen_string_literal: true

# Find and deactivate members keyed on the better-auth user id that the
# planner's id_token sub fallback used as an email (codebar planner,
# 2026-10-02 incident). These members share no name or activity evidence
# with their real account, so name/email duplicate heuristics cannot find
# them. The evidence is planner-side and deterministic: the member's email
# equals its own codebar auth service uid, that shared value contains no
# '@', and the member was created after the auth-flow cutoff.
#
# Cleanup is deactivate-only: no merge target is knowable from the planner
# database (the user-id-to-real-account mapping lives in the auth app's
# database), and guessing a merge target repeats the false-positive merge
# harm the duplicate tooling already guards against (member 31336 / 25796).
# A detected member owning data is skipped, never touched, and counts as
# handled: verify passes while skips are reported, so the "nothing
# unhandled" end state is reachable even when skips remain.
#
# Output is structured (Result/Action); the rake task owns all reporting.
class SubkeyedMemberCleanup
  RESULT_FIELDS = %i[detected deactivated skipped actions].freeze

  Action = Data.define(:member_id, :email, :outcome, :owned)
  Result = Data.define(*RESULT_FIELDS)

  # The merge of the /auth/codebar sign-in flow into planner (2026-08-06):
  # sub-keyed members cannot exist before this point.
  CUTOFF_TIME = Time.utc(2026, 8, 6, 15, 25, 11)

  # Email prefixes that mark a member already handled by this cleanup or by
  # the tooling it follows (the duplicate-merge rename and member deletion).
  HANDLED_EMAIL_PREFIXES = ['subkeyed.', 'duplicate.', 'deleted_user_'].freeze

  # Member associations that prove the member holds real data (skip rule):
  # any of these and the member is reported, not deactivated.
  OWNED_DATA = {
    subscriptions: 'subscriptions',
    workshop_invitations: 'workshop invitations',
    meeting_invitations: 'meeting invitations',
    invitations: 'event invitations',
    roles: 'roles',
    bans: 'bans',
    feedbacks: 'feedbacks',
    member_notes: 'member notes'
  }.freeze

  def self.call(dry_run: true)
    new(dry_run:).call
  end

  def initialize(dry_run: true)
    @dry_run = dry_run
  end

  def call
    actions = detectable_members.map { |member| deactivate(member) }

    Result.new(detected: actions.size,
               deactivated: actions.count { |a| a.outcome == :deactivated },
               skipped: actions.count { |a| a.outcome == :skipped },
               actions:)
  end

  def detectable_members
    prefix_exclusions = HANDLED_EMAIL_PREFIXES.map { |prefix| Member.where('members.email LIKE ?', "#{prefix}%") }

    prefix_exclusions.reduce(detection_scope) { |rel, exclusion| rel.where.not(id: exclusion) }
                     .order(:id)
                     .to_a
  end

  # Verify support: partition detectable members into the set this cleanup
  # can and should have deactivated (unhandled) and the set that owns data
  # (handled by report; never touched).
  def verification
    unhandled, skipped = detectable_members.partition { |member| data_owned_by(member).none? }
    { unhandled: unhandled.map(&:id), skipped: skipped.map(&:id) }
  end

  private

  def detection_scope
    Member.joins(:auth_services)
          .where(auth_services: { provider: 'codebar' })
          .where('members.created_at > ?', CUTOFF_TIME)
          .where('members.email = auth_services.uid')
          .where("position('@' in members.email) = 0")
  end

  def deactivate(member)
    owned = data_owned_by(member)
    return skipped_action(member, owned) if owned.any?

    return deactivated_action(member) if @dry_run

    persist_deactivation(member)
    deactivated_action(member)
  end

  def skipped_action(member, owned)
    Action.new(member_id: member.id, email: member.email, outcome: :skipped, owned:)
  end

  def deactivated_action(member)
    Action.new(member_id: member.id, email: member.email, outcome: :deactivated, owned: [])
  end

  def persist_deactivation(member)
    original_email = member.email
    ActiveRecord::Base.transaction do
      member.auth_services.destroy_all
      member.update_columns(email: "subkeyed.#{member.id}.deactivated@codebar.io") # rubocop:disable Rails/SkipsModelValidations -- renames fail normal validation by design
      member.member_notes.create!(note: note_body(original_email), author_id: member.id)
    end
  end

  def data_owned_by(member)
    OWNED_DATA.filter_map { |relation, label| label if member.public_send(relation).exists? }
  end

  def note_body(original_email)
    'Sub-keyed on the better-auth user id (id_token sub fallback). ' \
      "Original email/uid: #{original_email}. Deactivated #{Time.zone.now.iso8601}. " \
      'Login will stay off until the fail-closed strategy guard ships; re-login re-creates the member.'
  end
end
