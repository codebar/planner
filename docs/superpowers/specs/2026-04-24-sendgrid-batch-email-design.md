# Design: SendGrid Batch Email Migration for Workshop Invitations

**Date:** 2026-04-24  
**Status:** Draft — awaiting review  
**Goal:** Replace SMTP-based workshop invitations with SendGrid's v3 batch API, eliminating the 540-second DelayedJob timeout.

---

## 1. Overview

Workshop invitations currently go out via ActionMailer over SMTP. Each `deliver_now` blocks on network I/O; large chapters exceed the 9-minute `max_run_time`, killing jobs mid-send.

We will add a parallel delivery path using SendGrid's v3 API with dynamic templates:
- **Opt-in per chapter** — temporary migration table controls rollout
- **Restricted to admins and beta users** — separate UI
- **Fully reversible** — ActionMailer stays untouched
- **Incrementally adoptable** — start with `invite_student` and `invite_coach`
- **Idempotent** — retries never duplicate sends

---

## 2. Data Model

### `sendgrid_migration_configs` (temporary)

Maps chapters to SendGrid templates. No schema changes to `chapters`.

| Column        | Type     | Constraints  | Purpose                          |
|---------------|----------|--------------|----------------------------------|
| `id`          | serial   | PK           |                                  |
| `chapter_id`  | integer  | FK, not null | Enabled chapter                  |
| `email_type`  | string   | not null     | `invite_student`, `invite_coach` |
| `template_id` | string   | not null     | SendGrid dynamic template ID     |
| `from_email`  | string   | not null     | Sender address                   |
| `enabled_at`  | datetime | not null     |                                  |
| `disabled_at` | datetime | nullable     | Soft delete                      |

**Index:** `chapter_id + email_type` (unique, `disabled_at IS NULL`)

```ruby
SendgridMigrationConfig.enabled
  .find_by(chapter: workshop.chapter, email_type: "invite_student")
```

### `sendgrid_deliveries` (temporary)

Prevents duplicate sends on retry.

| Column        | Type     | Constraints  | Purpose                 |
|---------------|----------|--------------|-------------------------|
| `id`          | serial   | PK           |                         |
| `workshop_id` | integer  | FK, not null |                         |
| `member_id`   | integer  | FK, not null |                         |
| `email_type`  | string   | not null     |                         |
| `sg_batch_id` | string   |              | SendGrid `x-message-id` |
| `sent_at`     | datetime | not null     |                         |

**Index:** `workshop_id + member_id + email_type` (unique)

### Whitelist: Rolify role

Reuse the existing permission system:

```ruby
member.add_role(:sendgrid_beta)
```

```ruby
member.has_role?(:sendgrid_beta) || member.is_admin?
```

One line, zero migrations.

---

## 3. Service

### `SendgridBatchDeliveryService`

Lives in `app/services/`.

```ruby
class SendgridBatchDeliveryService
  BATCH_SIZE = 1_000
  RATE_LIMIT_DELAY = 1
  HTTP_OPEN_TIMEOUT = 30
  HTTP_READ_TIMEOUT = 60

  def initialize(workshop, email_type)
    @workshop = workshop
    @email_type = email_type
    @correlation_id = SecureRandom.uuid
  end

  def deliver!(members, logger: nil)
    config = fetch_config
    return false unless config

    invitations = create_invitations(members)
    unsent_invitations = filter_already_sent(invitations)

    if unsent_invitations.empty?
      logger&.finish_batch(0)
      return true
    end

    logger&.start_batch
    total_sent = 0

    unsent_invitations.each_slice(BATCH_SIZE).with_index do |batch, index|
      response = send_batch(config, batch, index + 1)

      if accepted?(response)
        record_deliveries(batch, response)
        batch.each { |invitation| logger&.log_success(invitation.member, invitation) }
        total_sent += batch.size
      else
        batch.each { |invitation| logger&.log_failure(invitation.member, invitation, api_error(response)) }
      end

      sleep RATE_LIMIT_DELAY
    end

    logger&.finish_batch(total_sent)
  rescue StandardError => e
    logger&.fail_batch(e)
    raise
  end

  private

  def fetch_config
    SendgridMigrationConfig.enabled
      .find_by(chapter: @workshop.chapter, email_type: @email_type)
  end

  def create_invitations(members)
    members.filter_map do |member|
      invitation = WorkshopInvitation.find_or_initialize_by(
        workshop: @workshop, member: member, role: role_from_email_type
      )
      invitation.save! if invitation.new_record?
      invitation
    rescue StandardError => e
      log_invitation_failure(member, e)
      nil
    end
  end

  def filter_already_sent(invitations)
    sent_member_ids = Set.new(
      SendgridDelivery.where(
        workshop: @workshop,
        email_type: @email_type
      ).pluck(:member_id)
    )

    invitations.reject { |inv| sent_member_ids.include?(inv.member_id) }
  end

  def send_batch(config, batch, batch_number)
    personalizations = build_personalizations(batch)
    return nil if personalizations.empty?

    data = {
      template_id: config.template_id,
      from: { email: config.from_email },
      personalizations: personalizations,
      mail_settings: { sandbox_mode: { enable: sandbox_mode? } }
    }

    client = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    start_time = Time.current

    response = client.client.mail._("send").post(request_body: data)

    log_response(response, batch, batch_number, Time.current - start_time)
    response
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    log_timeout(e, batch, batch_number)
    nil
  end

  def build_personalizations(invitations)
    invitations.filter_map do |invitation|
      member = invitation.member

      unless EmailValidator.valid?(member.email, mode: :strict)
        log_invalid_email(member)
        next
      end

      {
        to: [{ email: member.email }],
        dynamic_template_data: template_data_for(member, invitation),
        custom_args: {
          workshop_id: @workshop.id.to_s,
          member_id: member.id.to_s,
          batch_correlation_id: @correlation_id
        }
      }
    end
  end

  def template_data_for(member, invitation)
    {
      member_name: member.name,
      workshop_date: @workshop.date_and_time.strftime("%A %-d %B"),
      workshop_venue: @workshop.host&.name || "TBC",
      rsvp_url: invitation_url(invitation),
      unsubscribe_url: unsubscribe_url(member)
    }
  end

  def record_deliveries(batch, response)
    batch_message_id = response.headers["x-message-id"]
    now = Time.current

    rows = batch.map do |invitation|
      {
        workshop_id: @workshop.id,
        member_id: invitation.member_id,
        email_type: @email_type,
        sg_batch_id: batch_message_id,
        sent_at: now
      }
    end

    SendgridDelivery.insert_all(rows)
  end
end
```

**Key behaviors:**
- **Idempotency:** `sendgrid_deliveries` blocks duplicates; retries are safe.
- **Invitations:** Creates `WorkshopInvitation` records before sending, so RSVP tokens exist.
- **Email validation:** Invalid addresses are filtered out before building the batch. One bad email cannot kill 1,000 sends.
- **Batches:** 1,000 members per API call, with a 1-second pause between calls to avoid rate limits.
- **Custom args:** Every personalization carries `workshop_id`, `member_id`, and `batch_correlation_id` for future webhook matching.
- **Error handling:** 4xx/5xx and timeouts log full context (member IDs, batch number, correlation ID).
- **Auto-retry:** DelayedJob retries are safe. `max_attempts = 3` with exponential backoff.
- **Structured logging:** Every batch logs `event`, `workshop_id`, `batch_number`, `duration_ms`, `sg_message_id`, and `correlation_id`.
- **InvitationLogger:** Logs `start_batch`, `log_success`/`log_failure` per member, and `finish_batch`.
- **Atomic inserts:** `sendgrid_deliveries` rows are inserted with `insert_all` in a single statement.

---

## 4. UI and Routes

### Routes

```ruby
get "/admin/workshops/:id/sendgrid_invitations", to: "admin/sendgrid_invitations#new"
post "/admin/workshops/:id/sendgrid_invitations", to: "admin/sendgrid_invitations#create"
```

### Controller: `Admin::SendgridInvitationsController`

- `before_action :authenticate_admin_or_whitelisted!`
- `new`: Renders the form
- `create`: Enqueues `SendgridBatchDeliveryJob` via `perform_later`

### View: `app/views/admin/sendgrid_invitations/new.html.haml`

- Beta explanation banner
- Audience selector: `students`, `coaches`, `everyone`
- "Send invitations via SendGrid" button
- Link back to regular invitation page
- `sendgrid_deliveries` count (e.g., "47 of 250 sent")

### Visibility

Only global admins and members with `:sendgrid_beta` role see the route and nav link.

---

## 5. SendGrid Templates

### Scope: `invite_student` and `invite_coach`

Highest-volume, simplest templates. No `.ics` attachments needed here — `attending` confirmations stay on ActionMailer.

### Variables

| Variable          | Example                                   | Source                       |
|-------------------|-------------------------------------------|------------------------------|
| `member_name`     | "Alice"                                   | `member.name`                |
| `workshop_date`   | "Tuesday 25 March"                        | `@workshop.date_and_time`    |
| `workshop_venue`  | "CodeNode, London"                        | `@workshop.host.name`        |
| `rsvp_url`        | `https://codebar.io/invitations/abc123`   | `invitation_url(invitation)` |
| `unsubscribe_url` | `https://codebar.io/unsubscribe/abc123`   | `unsubscribe_url(member)`    |

### HTML (Handlebars)

```html
<p>Hi {{member_name}},</p>
<p>You're invited to our workshop on {{workshop_date}} at {{workshop_venue}}.</p>
<a href="{{rsvp_url}}">RSVP here</a>
<a href="{{unsubscribe_url}}">Unsubscribe</a>
```

Rails stores only the template ID. CSS must be inlined manually in SendGrid's UI; `premailer-rails` does not run on dynamic templates.

---

## 6. Errors and Observability

### API Responses

| Response                | Meaning         | Action                                       |
|-------------------------|-----------------|----------------------------------------------|
| `202 Accepted`          | Batch queued    | Record in `sendgrid_deliveries`, log success |
| `400 Bad Request`       | Invalid payload | Log error, alert admin                       |
| `401 Unauthorized`      | Bad API key     | Log error, alert admin                       |
| `403 Forbidden`         | Account issue   | Log error, alert admin                       |
| `429 Too Many Requests` | Rate limit      | Log error, parse `Retry-After`, advise admin |

### Logging

Every batch emits a structured log line:
- `event`: `sendgrid_batch_accepted` | `sendgrid_batch_failed` | `sendgrid_batch_timeout`
- `workshop_id`, `email_type`, `batch_number`, `batch_size`
- `duration_ms`, `sg_message_id`, `correlation_id`
- `member_ids` (on failure)

**Search:**
```bash
heroku logs --app codebar | grep "correlation_id=abc-123-def"
```

**Query:**
```ruby
# How many were sent?
SendgridDelivery.where(workshop_id: 123, email_type: "invite_student").count

# Who wasn't sent?
sent_ids = SendgridDelivery.where(workshop_id: 123).pluck(:member_id)
all_ids = chapter_students(chapter).pluck(:id)
all_ids - sent_ids
```

### Optional: `sendgrid_batches` table (P2)

For per-batch status in the UI without grepping logs:

```ruby
sendgrid_batches
  - workshop_id, email_type, batch_number, status
  - http_status, error_message, member_count, started_at, completed_at
```

### No webhook (Phase 1)

We rely on synchronous API logging, `sendgrid_deliveries`, and the SendGrid dashboard. Webhook comes in Phase 3; `custom_args` are already in place for it.

---

## 7. Testing

### Unit tests

`spec/services/sendgrid_batch_delivery_service_spec.rb`:
- Builds correct personalizations
- Splits into batches of 1,000
- Skips already-sent members (idempotency via `Set`)
- Skips invalid emails
- Creates `WorkshopInvitation` records
- Uses `insert_all` atomically
- Integrates with `InvitationLogger`
- Logs errors on 4xx/5xx and timeouts
- Records `sendgrid_deliveries` on 202
- Is safe to retry

Use WebMock to stub SendGrid API.

### Feature tests

`spec/features/admin/sendgrid_invitations_spec.rb`:
- Admin sees form
- Admin sends invitations
- Non-beta user gets 404
- Retry is idempotent

### Integration test

`spec/integration/sendgrid_sandbox_spec.rb`:
- One test against SendGrid sandbox mode (`:external`)
- Validates payload format without sending real email
- Controlled by `ENV["SENDGRID_SANDBOX_MODE"]`

---

## 8. Rollout

### Phase 1: Infrastructure (this PR)
- `sendgrid_migration_configs` and `sendgrid_deliveries` tables
- `sendgrid-ruby` gem
- `:sendgrid_beta` Rolify role
- `SendgridBatchDeliveryService`
- `Admin::SendgridInvitationsController` + views
- Tests

### Phase 2: First template
- Design `invite_student` in SendGrid UI
- Add config row for one test chapter
- Admin sends test batch
- Monitor logs and `sendgrid_deliveries`

### Phase 3: Expand
- Add `invite_coach` template
- Enable second chapter
- Gather organiser feedback
- Add Event Webhook (optional)

### Phase 4: Full migration (future PRs)
- Migrate `attending` confirmations (needs `.ics` strategy)
- Migrate event and meeting invitations
- Drop ActionMailer/SMTP path
- Drop temporary tables (or keep for analytics)

---

## 9. Open Questions

1. **API key scope:** Restrict to `mail.send` only? (Recommended)
2. **Rate limits:** What SendGrid tier are we on?
3. **Template versioning:** Store version IDs or use the active version?

---

## 10. Risks

| Risk                           | Mitigation                                                  |
|--------------------------------|-------------------------------------------------------------|
| SendGrid API down              | ActionMailer fallback                                       |
| Wrong or deleted template ID   | Validate via Templates API before sending                   |
| Batch fails mid-send           | `sendgrid_deliveries` tracks sent members; retry skips them |
| Rate limit exceeded            | 1-second delay between batches; parse `Retry-After`         |
| Data leaks in personalizations | Pass only name and email; no PII                            |
| Duplicate sends on retry       | `sendgrid_deliveries` unique constraint                     |

---

## 11. Dependencies

- `sendgrid-ruby` gem
- `ENV["SENDGRID_API_KEY"]` (separate from SMTP credentials)
- `ENV["SENDGRID_SANDBOX_MODE"]` (optional)
- SendGrid account with Dynamic Templates

---

**Next step:** Write implementation plan.
