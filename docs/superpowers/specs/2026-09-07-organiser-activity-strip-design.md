# Organiser Activity Weekly Strip Design

Date: 2026-09-07

## Problem

Admins cannot tell at a glance whether an organiser is still active. The admin member profile shows profile data and roles, but nothing about what the member has been doing over time. Dormancy is invisible until an outreach conversation, and there is no shared, append-only record of member activity to build future admin tooling on.

Goal: a GitHub-contribution-style weekly activity strip on the admin member profile, backed by a single append-only activity log covering member actions (logins, logouts, subscriptions, RSVPs, profile edits), organiser actions, and relevant admin actions. This design extends the stashed organiser activity design (`branch spec/organiser-activity`, content preserved in the wiki) and the approved admin dashboard design (`2026-09-04-admin-dashboard-design.md`).

## Decisions

- **One append-only log, reused table.** All actions are recorded on the existing `activities` table (`public_activity` gem; already installed, migrated, and wrapped by `Auditor::Audit`). No new table, no migration. Rows are created and never updated. The stashed design's approach B (an event log) is realised without new machinery.
- **Log-only history.** Weeks before deploy read as empty. No backfill; no union with legacy tables (`invitations`, `invitation_logs`, `member_notes`). History self-heals as the log accumulates. The log is the single source going forward.
- **Three-state cells.** Empty (nothing that week), dim (logins/logouts only), solid (at least one other action). Intensity encodes signal quality, not volume.
- **12-month window.** 52 ISO-week cells ending the current week, matching the stashed design's `silent` bucket boundary.
- **All member activity counts, not only organiser actions.** A member's own RSVPs, subscriptions, and check-ins light cells too.
- **Profile edits count.** Deliberate choice: profile-edit signal helps reveal misuse and account takeovers.
- **Admin entity CRUD does not count.** Events, meetings, chapters, sponsors, announcements, groups, testimonials, and workshop sponsor/host edits are entity management, not member activity. Known gap with a built-in check: if the `/admin/organisers` overview shows admins drifting to `quiet` while clearly working, revisit.
- **Visualisation only in this design's second PR.** Strip rendering is separate from instrumentation so the log accumulates while the UI ships.

## Data model

No schema changes. The `activities` table is used as follows:

| Column | Meaning |
|---|---|
| `owner` (polymorphic) | The acting member, always. The strip groups by this. |
| `key` | Dotted action name, e.g. `member.login`. |
| `trackable` (polymorphic) | The affected object (invitation, subscription, group, workshop, note). |
| `recipient` (polymorphic) | For actions on another member: the affected member. |
| `created_at` | Week bucketing. |

The existing `(owner_id, owner_type)` index serves the strip's query. No backfill; history starts at deploy.

## Recorder

`MemberActivityRecorder` service (~5 lines), the single funnel for member-activity rows:

```ruby
MemberActivityRecorder.record(actor:, key:, trackable: nil, recipient: nil)
```

- Explicit call sites only — no model callbacks, so nothing is double-logged.
- `key` comes from a closed list of dotted action names (see Instrumentation).
- Recording failures must not break user flows: the recorder rescues and logs record-creation errors rather than raising. Activity logging is observability, not business logic. (Note: `Auditor::Audit` does not rescue; the recorder is deliberately stricter.)

## Instrumentation

Write sites, one line each, at the point where the actor is known. Completeness audited against all member-facing and admin controllers on 2026-09-07.

### Member actions (session-authenticated)

| Site | Key |
|---|---|
| `AuthServicesController#create` | `member.login` |
| `ApplicationController#logout!` | `member.logout` |
| `SubscriptionsController#create` / `#destroy` | `subscription.created` / `subscription.removed` (trackable: group) |
| `MailingListsController#create` / `#destroy` | `mailing_list.subscribe` / `mailing_list.unsubscribe` |
| `InvitationsController#attend` / `#reject` / `#rsvp_meeting` | event/meeting RSVPs (trackable: invitation) |
| `MembersController#update`, `Member::DetailsController#update` | `profile.updated` |
| `TermsAndConditionsController#update` | `toc.accepted` |
| `AuthServicesController#destroy` | `auth_service.removed` (provider unlink) |

### Member actions (token-authenticated, no session)

The invitation token is the authenticator for these paths; there is no `current_user`. The actor is `@invitation.member`, passed explicitly.

| Site | Key |
|---|---|
| `WorkshopInvitationController#accept` / `#reject` | `workshop_invitation.rsvp` / `workshop_invitation.rejected` (the main workshop RSVP path) |
| `WaitingListsController#create` / `#destroy` | `waiting_list.joined` / `waiting_list.left` |

### Login capture detail

`AuthServicesController#create` currently sets `session[:member_id]` in two branches (existing auth service; newly created member). Both branches funnel through one private `sign_in!(member)` method that sets the session values and records `member.login`. The funnel prevents a missed branch from silently dropping login records.

### Admin actions

| Site | Key | Notes |
|---|---|---|
| `Admin::Chapters::OrganisersController#create` / `#destroy` | `organiser_role.granted` / `organiser_role.revoked` | recipient: the member. Core signal for this feature. |
| `InvitationLogger` | `invitation.send_batch` | owner: initiator (already attributed). |
| `Admin::InvitationsController` overrides | `invitation.rsvp_override` | recipient: overridden member. |
| `Admin::InvitationController#verify` | `invitation.verified` | recipient: invited member. |
| `Admin::MemberNotesController#create` | `member_note.created` | recipient: noted member. |
| `Admin::WorkshopsController#create` | `workshop.created` | plus `workshops.created_by_id` (migration, `on_delete: :nullify`). |
| `CheckInsController#mark_attended` | `member.checked_in` | recipient: checked-in member; covers both self-service check-in and admin marking. |
| `Admin::MembersController#update_subscriptions` | `subscription.admin_updated` | recipient: member. |
| `Admin::MeetingInvitationsController#create` / `#update` | `meeting_invitation.created` / `meeting_invitation.updated` | recipient: invited member. |
| `Admin::BansController#create` | `member.banned` | owner: admin, recipient: banned member. |

### Excluded sites

- Admin entity CRUD (events, meetings, chapters, sponsors, announcements, groups, testimonials, workshop sponsor/host edits, workshop updates/destroys) — see Decisions.
- Feedback submission (`FeedbackController#submit`) — no submitter attribution exists (`feedbacks` has only `coach_id`).
- Waiting-list auto-promotion — actor-less model logic.
- `WorkshopInvitationController#update` and invitation detail updates — low signal.

## Service

`Admin::Members::ActivityStrip` (data-only rows, following the repo's service-object convention and the admin dashboard design's pattern).

- Input: a `Member`.
- Query: `PublicActivity::Activity.where(owner: member).where(created_at: window)`, window = the 52 ISO weeks ending the current week. One indexed query.
- Bucketing: group by ISO week; per-week state:
  - `:empty` — no rows.
  - `:login_only` — rows exist, all with keys `member.login` / `member.logout`.
  - `:active` — at least one row with any other key.
- Output: an array of 52 weekly structs with `week_start`, `state`, and counts per key for tooltips. Monotonic ordering, oldest first.
- The service is the sole owner of state-classification logic; the component renders, it does not classify.

## Component and placement

- `Admin::Members::ActivityStripComponent` (ViewComponent + ERB, following `Admin::ChapterStatus::TableComponent`).
- Single row of 52 tall rectangles (GitHub-status.com style: narrow vertical bars), SVG or CSS, no new JavaScript.
- Placement: `/admin/members/:id` (`Admin::MembersController#show`), in `app/views/admin/members/_profile.html.haml`. Not the member-facing `/profile`.
- Renders only when the viewed member holds an organiser role on any chapter (Rolify check, same as existing role checks in the profile).
- Tooltips carry per-week detail, e.g. "Week of 3 Mar: 2 logins, ran Bash workshop".
- Drift signal: a trailing run of empty weeks is visible in the rendering itself; no separate badge.

## Performance

One indexed query per profile view, admin-only, single member, low traffic. No caching.

## Testing

- Recorder: each instrumented site creates exactly one row with the expected key, owner, trackable, and recipient. Login through the OAuth callback (both `AuthServicesController#create` branches) records `member.login` once. Token-based RSVP and waiting-list actions record against `@invitation.member`. A recorder failure (stubbed record error) does not raise out of the controller action.
- Service: ISO-week bucket boundaries; the three states; a member mixing keys; a member with no activity; the 52-week window ends at the current week.
- Component: renders three states; tooltip content; absent for non-organisers.
- Request-level: admin-only access to the profile page; unauthenticated requests redirected.

## Out of scope

- The `/admin/organisers` overview table (stashed design, separate slice).
- Chapter health quantification.
- Per-action-type detail views (the log's `key` granularity is the upgrade path).
- Anything member-facing.
- GDPR erasure of activities.
- Backfill or legacy-table unions.

## Delivery plan

Two PRs, mirroring the stashed design's plumbing/page split:

1. **Instrumentation.** `MemberActivityRecorder`, `sign_in!` funnel in `AuthServicesController`, all write sites from the Instrumentation section, `workshops.created_by_id` migration. No UI change. Ships the log accumulation immediately.
2. **Visualisation.** `Admin::Members::ActivityStrip` service, `ActivityStripComponent`, profile integration. No new instrumentation.
