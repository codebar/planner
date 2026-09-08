# Self Check-In Design

## Summary

Allow attendees at events and workshops to mark themselves as attended via a QR code. Organisers download a landscape PDF containing the QR code, event info, venue, and sponsors. The PDF can be printed, displayed on screens/projectors, or sent to venue hosts ahead of time — no internet connection required. Each event/workshop gets a unique 3-word code that shortens the QR URL. After scanning, the attendee authenticates, confirms their role, and is checked in.

## Routes

```
# Admin — instructions page (HTML) + PDF download (same URL, .pdf format)
GET  /admin/events/:slug/check-in     → admin/check_ins#show
GET  /admin/workshops/:id/check-in    → admin/check_ins#show

# Public — check-in flow (what the QR encodes)
GET  /check-in/e/:code  → check_ins#new  (event)
POST /check-in/e/:code  → check_ins#create
GET  /check-in/w/:code  → check_ins#new  (workshop)
POST /check-in/w/:code  → check_ins#create
```

No public display pages. The PDF is the display.

## Data Model

Add a `check_in_code` column to both `events` and `workshops`:

- Type: string, unique per table, indexed
- Generated on `before_create` from the EFF word list (3 random words)
- Retry on collision
- Existing records: generate the code on first PDF download (or via a one-time rake task)

Add a `source` column to `workshop_invitations` and `invitations`:

- Type: string, nullable (no default)
- Valid values: `"email"`, `"check_in"`, `"admin"`
- `NULL` = legacy records, no backfill needed
- Every new code path sets it explicitly

No new tables.

## Word List

Bundle the [EFF large word list](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt) as `lib/words/check_in_words.txt`.

- 7,776 common English words, curated to exclude offensive terms
- Diceware-derived, work-safe
- Stripped of diceware numbers on import — just the word column

Three random words from 7,776 gives ~470 billion combinations. Collision probability for any realistic number of events/workshops is negligible. Generate and validate uniqueness in a loop (typically 1 attempt).

## QR Code Generation & PDF

### Gems to add

- `rqrcode` — QR code matrix calculation + PNG rendering
- `prawn` — PDF generation (pure Ruby, no native deps)

### QR Code

Generate the QR as PNG, embed in the PDF:

```ruby
qrcode = RQRCode::QRCode.new(check_in_url)
png = qrcode.as_png(module_size: 4, resize_gte_to: false)
```

The QR encodes the full public check-in URL, e.g. `https://codebar.io/check-in/e/sunny-ocean-breeze`.

### PDF Layout (Landscape A4)

Generated on-the-fly when the admin downloads it. No storage, no background job needed.

Content:
- **Header**: codebar logo (optional v1, text is fine)
- **Event info**: name, date, time — large, bold, readable at a distance
- **Venue**: name and address
- **Sponsors**: listed below venue (names, logos deferred to v2)
- **QR code**: large, centred, ~200×200px
- **URL**: below QR in monospace: `codebar.io/check-in/e/sunny-ocean-breeze`
- **Label**: "Scan to check in" above the QR
- Background: white, black text, minimal ink usage

Embedded in the PDF via `Prawn::Document#image` with the PNG blob.

### Note on `check_in_code` generation

Generated on `before_create` for new records. For existing records, generated lazily on first PDF download — the admin action checks for nil and creates one before rendering the PDF. This is a deliberate side effect on a download action (not a pure read).

## Check-In Flow (Public)

1. Member scans QR or types the URL → hits `CheckInsController#new`
2. If already logged in: skip to step 5.
3. If not logged in: set `session[:referer_path] = request.path`, call `authenticate_member!` → redirects to `/auth/github`. After GitHub auth, `AuthServicesController#create` uses `referer_or_dashboard_path` → sends them back to the check-in page. No changes needed to `AuthServicesController`.
4. If logged in but profile incomplete: redirect through existing `edit_member_details` flow. After completion, `session[:referer_path]` returns them to the check-in page.
5. `CheckInsController#new` renders the role-selection page:
   - Member's name
   - Event/workshop title and date
   - Two large buttons: **[I'm a Student]** **[I'm a Coach]**
   - Button highlighting logic:
     - Existing invitation with known role → that button highlighted
     - No invitation but one group subscription → that button highlighted
     - Both groups or no groups → both shown equally, no highlight
   - If already checked in: show "You're already checked in as [role] ✓"
6. Member clicks role → `POST CheckInsController#create` with `role`
7. Controller finds or creates the invitation. Sets `source="check_in"` plus:

   | Table | Fields set |
   |-------|-----------|
   | `workshop_invitations` | `attending=true`, `attended=true`, `source="check_in"` |
   | `invitations` (events) | `attending=true`, `verified=true`, `source="check_in"` |

   Events have no `attended` column — check-in maps to `verified` (physical presence substitutes for admin verification).

8. Redirects to confirmation: "You're checked in as a Student at Summer Workshop 2026"
9. Confirmation has a "Back to Dashboard" link

### Edge Cases

- **Already attended:** Already `attended`/`verified` → re-show success, no duplicate
- **Existing invitation (not yet attended):** `attending=true` but `attended=nil`/`verified=false` → update
- **New member (no groups):** Both buttons, no highlight. Invitation created, no subscription inferred.
- **Event with `confirmation_required`:** Physical presence = verified, so `verified=true`
- **Workshop at capacity:** `attended` is independent of spot counting — always set
- **Past event:** No time restriction — venue presence is the only gate

## Admin Integration

In the admin event/workshop show page toolbar, a button labelled "Check-in" that opens the instructions page at `/admin/events/:slug/check-in` (or `/admin/workshops/:id/check-in`) in the same tab. The instructions page then has a "Download PDF" button.

The existing `admin/workshop/attendance_row` partial already has admin checkboxes for marking `attended` on workshop invitations. These remain the admin interface for manual attendance verification. Self check-in is a parallel path.

### Admin Controller — `show` action

Uses `respond_to` to serve HTML (default) or PDF:

```ruby
def show
  @parent = find_parent  # event or workshop, polymorphic
  authorize @parent
  generate_check_in_code_if_missing

  respond_to do |format|
    format.html  # instructions page (default)
    format.pdf do
      pdf = CheckInPdf.new(@parent).render
      send_data pdf,
                filename: "check-in-#{@parent.to_param}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end
  end
end
```

### Instructions page content

The HTML page guides the organiser through the feature:

- **Title**: "Check-in for [Event/Workshop Name]"
- **What this is**: "Let attendees mark themselves as attended by scanning a QR code."
- **Check-in code** and **URL**: displayed prominently (so the organiser can share the URL verbally if someone can't scan)
- **How to use**:
  1. Download the PDF
  2. Print it or display it on a screen at the venue entrance
  3. Attendees scan the QR code with their phone
  4. They sign in with GitHub and select their role (Student/Coach)
  5. They're checked in — you can see attendance in the event/workshop admin page
- **Download PDF button**: links to the same URL with `.pdf` format (e.g. `/admin/events/summer-2026/check-in.pdf`)
- Uses the standard admin layout, consistent with the rest of the admin section

## Existing Code Changes

The `source` column must be set in all invitation-creation paths:

| Location | Set `source` to |
|----------|----------------|
| `InvitationManager#invite_students_to_event` and friends | `"email"` |
| `InvitationManager#create_invitation` (workshop email path) | `"email"` |
| `Admin::InvitationsController#update_to_attending` (admin adds attendee) | `"admin"` |
| `Admin::InvitationController##verify` (admin verifies event attendee) | `"admin"` |
| `CheckInsController#create` (self check-in) | `"check_in"` |
| `EventsController#rsvp` (Tito webhook) | `"email"` |
| `EventsController#student` / `#coach` (public event RSVP) | `"email"` |
| `WorkshopsController#rsvp` (public workshop RSVP) | `"email"` |

## Implementation Order

1. Migration: add `check_in_code` to events + workshops (unique, indexed), add `source` to workshop_invitations + invitations (nullable)
2. Model changes: `before_create` generates `check_in_code` from EFF word list. Existing records get one lazily on first PDF download.
3. Bundle EFF word list as `lib/words/check_in_words.txt`
4. Add `rqrcode` and `prawn` gems
5. Build `CheckInPdf` service object — takes an event or workshop, renders a landscape PDF
6. Build `Admin::CheckInsController` — `show` action with `respond_to` (HTML instructions + PDF download)
7. Build admin instructions page view for check-in
8. Update existing code paths to set `source` (InvitationManager, admin controllers, public RSVP controllers)
9. Build `CheckInsController` (public): `new` (auth gate + role selection), `create`, confirmation
10. Build views: role-selection page, confirmation page
11. Admin toolbar: "Check-in" button on event/workshop show pages linking to instructions page
12. Routes (admin + public, as above)

## Controller Design

**`Admin::CheckInsController`:** Single action (`show`) with `respond_to` for HTML and PDF. Polymorphic parent loading by slug (events) or id (workshops). Requires admin/organiser auth. Generates `check_in_code` if missing on first visit. HTML page provides instructions and download link. PDF response streams the generated document.

**`CheckInsController` (public):** Two check-in actions (`new`, `create`, plus `confirm`). Detects parent type from URL prefix (`/check-in/e/` vs `/check-in/w/`). Loads by `check_in_code`. `create` branches on parent type for field mapping.

**`CheckInPdf` service object:** Takes a parent (event or workshop), builds a `Prawn::Document` with landscape layout. Handles QR generation via `rqrcode`, text layout via `prawn`.
