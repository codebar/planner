---
type: feat
origin: none
issue: codebar/planner#2384
artifact_readiness: implementation-ready
---

# Signup nudge email sequence (issue #2384)

Automated emails to members who signed up via the website but never subscribed to a chapter: a nudge 7–14 days after signup and a follow-up one month later, then the sequence ends. Built on the typed `member_email_deliveries` log shipped in #2832 (`email_type` column + unique index on `(member_id, email_type)`).

## Key Technical Decisions

- **Shared typed log as sequence state** — `session-settled: user-approved` (class: user-approved; rejected alternative: dedicated `signup_nudges` table; also rejected: boolean flags on `members`). Stage eligibility is derived from `member_email_deliveries` rows; no new state store.
- **Stage 1 window 7–14 days after signup** — `session-settled: user-approved` (class: user-approved; rejected alternatives: strict one-day window, rolling `<= 7 days` window). Wide enough to absorb scheduler gaps, narrow enough to exclude the historical never-subscribed backlog from the day of deploy.
- **Stage 2 anchored to stage 1's send time** — `session-settled: user-approved` (class: user-approved; rejected alternative: fixed member age). Follow-up lands exactly one month after the nudge regardless of when a run picked up the member.
- **Audience includes abandoned signups** — `session-settled: user-directed` (class: user-directed; rejected alternative: `accepted_toc`-only). Members who never completed signup receive the nudge.
- **Dedupe is delivery-confirmed** — rows are written by the `EmailDelivery` concern after delivery; there is no pre-enqueue stamping. Rejected alternative: stamp-before-enqueue (at-most-once) — loses the "lost nudge" self-healing within the stage-1 window.
- **No `member_email_deliveries` exclusion coupling** — the chaser's exclusion is already scoped to `email_type: 'chaser'` (#2832); nudge rows cannot suppress chaser emails.

## Implementation Units

### U1 — Mailer actions and views

- **Goal:** two member-facing emails that opt into the typed delivery log.
- **Files:**
  - Modify `app/mailers/member_mailer.rb`
  - Create `app/views/member_mailer/signup_nudge.html.haml`
  - Create `app/views/member_mailer/signup_nudge_followup.html.haml`
- **Approach:**
  - `def signup_nudge` — subject and copy TBD (placeholder until copy arrives from Kimberley); `mail_to_member(member, subject, 'hello@codebar.io')`; rendered via `signup_nudge.html.haml`.
  - `def signup_nudge_followup` — same shape, second subject/copy.
  - `after_deliver :log_sent_email, only: [:chaser, :signup_nudge, :signup_nudge_followup]`.
- **Test scenarios:**
  - Each action renders headers (to/from) and non-empty body containing its distinctive copy.
  - Delivery creates a `MemberEmailDelivery` row with the action's `email_type`.

### U2 — Sequence service

- **Goal:** one service computes both stages' eligible members per daily run and sends.
- **Files:**
  - Create `app/services/signup_nudge_email_service.rb`
- **Approach:**
  - `def self.send_nudges`
  - Stage 1 (nudge): `Member.not_banned` where `created_at` falls on the 7..14-days-ago window, `where.not(id: Subscription.select(:member_id))`, `where.not(id: MemberEmailDelivery.where(email_type: 'signup_nudge').select(:member_id))`; `MemberMailer.with(member:).signup_nudge.deliver_later` per member.
  - Stage 2 (follow-up): `Member.not_banned` with a `signup_nudge` row `created_at <= 1.month.ago`, no `signup_nudge_followup` row, `where.not(id: Subscription.select(:member_id))`; `MemberMailer.with(member:).signup_nudge_followup.deliver_later`.
  - No `accepted_toc` filter (abandoned signups included). No `unsubscribed` filter (nothing sets it; the chaser ignores it too).
- **Test scenarios:**
  - Sends nudge to a member created 10 days ago with no subscription; follow-up to a member whose nudge row is 6 weeks old.
  - Skips: subscribed members, banned members, members with the stage's row already present, members younger than 7 days, members older than 14 days without a nudge row, follow-up for a member whose nudge row is 3 weeks old, follow-up for a member with no nudge row.
  - Terminal state: a member with both rows receives nothing from either stage.

### U3 — Job and rake task

- **Goal:** the daily entry point, mirroring the chaser's wiring.
- **Files:**
  - Create `app/jobs/send_signup_nudge_email_job.rb`
  - Modify `lib/tasks/chaser.rake`
- **Approach:** `SendSignupNudgeEmailJob` (queue `:default`) calls `SignupNudgeEmailService.send_nudges`; rake task `chaser:signup_nudges` enqueues the job; the namespace description is updated to cover both emails.
- **Test scenarios:**
  - The rake task enqueues the job (existing chaser rake-task spec pattern).

### U4 — Ops handoff

- **Goal:** the sequence actually runs daily in production.
- **Files:** none (dashboard-side).
- **Approach:** PR description carries an ops note: add a Heroku Scheduler entry `rake chaser:signup_nudges` (daily), same as the existing `rake chaser:three_months` entry; without it the feature ships dark.
- **Test scenarios:** none.

## Verification

- `make test` (parallel RSpec) green; new specs for U1–U3; existing `three_month_email_service` specs unaffected (chaser exclusion already typed).
- Manual letter-opener check of both emails in development.
- After merge: confirm the first scheduled run creates `signup_nudge` rows for the current 7–14-day cohort. Owner: Morgan.

## Risks & Dependencies

- **Copy dependency:** both subjects/bodies are placeholders until Kimberley provides copy via Slack (per the issue). The PR can be reviewed and held; copy lands as a follow-up commit before merge.
- **Volume:** cohorts are 0–3 members/day (verified against the production dump). A stage-1 catch-up run is bounded by the 8 daily cohorts in the 7–14-day window (≤ ~24 emails); a stage-2 catch-up after a long outage is bounded by the accumulated `signup_nudge` population rather than the two-week window.
- **Deploy-time boundary:** members older than 14 days at merge never enter the sequence — accepted, bounded.
- **Edge cases accepted:** a member who subscribes and unsubscribes within the month re-enters stage 2; a member whose stage-1 send failed (e.g. invalid email → `SkippedEmail`) gets no stage-1 row and therefore no stage 2 (under-send bias).
