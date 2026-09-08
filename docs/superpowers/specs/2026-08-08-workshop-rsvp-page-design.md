# Design: Workshop "RSVP members" page (replace the 4k-item dropdown)

Date: 2026-08-08
Status: Draft for review
Issue: #2796 (follow-up improvement)

## Problem

The admin workshop show page carries an RSVP `<select>` listing every
**outstanding invitation** (`workshop.invitations.not_accepted`) for the
workshop — up to 4,337 options on large workshops. Even after the N+1 fix
(PR #2797), generating that list and feeding it to Chosen costs ~2.5 s of view
time and ~8M allocations for data the control is rarely used for. The control
is only meaningful on the rare occasion an organiser wants to RSVP a specific
member by hand; loading the whole list every time an organiser views a
workshop is wasteful.

## Goal

Move that functionality to a dedicated **RSVP members** page for the workshop:

- The workshop show page no longer loads the invitation list at all; it links
  to the new page instead.
- The new page is **search-driven**: no members are loaded on page load. The
  organiser searches by member name; matching invited members come back
  **paginated** (Pagy).
- Each result row has a **toggle button** that flips that member's RSVP state
  (attending <-> not attending).

## Scope

Search pool is members who already have an **invitation row for this
workshop** (any attending state, so already-attending members can be toggled
off), **excluding banned members**. No invitation-creation logic — RSVPing is
only ever applied to an existing invitation.

## Design

### Route

Add to the admin workshops resource:

```ruby
resources :workshops do
  member do
    get 'rsvp'   # admin_workshop_rsvp_path(@workshop)
  end
end
```

### Controller

New action on `Admin::WorkshopsController`:

```ruby
def rsvp
  set_workshop
  authorize @workshop, :update?

  @eligible_count = @workshop.invitations
                             .joins(:member)
                             .merge(Member.not_banned)
                             .count

  return unless params[:q].present?

  @pagy, @invitations = paginate_matching_invitations(params[:q])
end

def paginate_matching_invitations(query)
  eligible = @workshop.invitations
                      .joins(:member)
                      .merge(Member.not_banned)
  invitations = eligible.merge(Member.find_members_by_name(query))
                        .includes(:member)
                        .order('members.name, members.surname')
  pagy(invitations, items: 20)
end
```

Notes:

- `Member.find_members_by_name` already exists: `ILIKE` on
  `CONCAT(name, ' ', surname)`.
- The eligible-member **count is a single cheap COUNT query** shown on every
  page load (e.g. "1,234 invited members") so the organiser knows the size of
  the pool. It materialises no member rows, so it does not violate the
  no-loading rule.
- No search term -> no member *rows* are loaded. Page renders the search box,
  the eligible count, and a prompt only. (`pagy` on a base relation would
  count the full set; we avoid building the scope at all when `q` is blank.)
- `set_workshop` + `authorize` reuse existing behaviour; `:update?` matches the
  permission required to mutate invitations.

### View — `app/views/admin/workshops/rsvp.html.haml`

- **Back link** at the top: `= link_to "Back to #{@workshop}", admin_workshop_path(@workshop)` (breadcrumb style, matching admin conventions).
- **Heading**: "RSVP members" plus the eligible pool size, e.g. "1,234 invited members" (from `@eligible_count`), rendered on every page load.
- **Search form**: single text input for member name, GET to `admin_workshop_rsvp_path`, explicitly preserving the workshop. Mirrors the `admin/member_search/_search_form` partial pattern.
- **No search term**: nothing else on the page but a hint, e.g. "Search for a member to RSVP".
- **Results**: table with columns:
  - Member (name, email)
  - Role (Student / Coach — from the invitation row)
  - Status badge (Attending / Not attending)
  - Action: **Toggle RSVP** button
- **No matches**: "No members found for '<q>'".
- **Pagination**: `= render partial: 'shared/pagination', locals: { pagy: @pagy, model: 'invitation' }` when there are results.

### Toggle

Each row is a small form:

```haml
= form_tag admin_workshop_invitation_path(@workshop, invitation), method: :put do
  = hidden_field_tag :attending, invitation.attending? ? 'false' : 'true'
  = submit_tag invitation.attending? ? 'Mark as not attending' : 'RSVP', class: 'btn btn-sm btn-outline-primary'
```

This posts to the **existing** `Admin::InvitationsController#update`, which
already handles both directions (sets `attending`, `rsvp_time`,
`automated_rsvp`, `last_overridden_by_id`; sends the attending email when the
workshop is upcoming; clears the waiting-list row). Its non-XHR branch does
`redirect_back`, returning the organiser to the rsvp page with search + page
preserved. No new mutation code, no JS.

### Invitation management partial

In `app/views/admin/workshops/_invitation_management.html.haml`, replace the
`<select>` + outstanding-count block with:

```haml
= link_to "RSVP a member", admin_workshop_rsvp_path(@workshop), class: 'btn btn-sm btn-outline-primary'
```

The workshop show page stops querying `invitations.not_accepted` entirely.

### N+1 safety

`paginate_matching_invitations` eager-loads member (`includes(:member)`); the
row rendering touches only invitation and member attributes. Pagination is 20
rows, so allocation is bounded regardless of workshop size.

## Error handling

- Blank/whitespace search term -> same as no search (no query).
- Search term with no matches -> "No members found" message, no error.
- Toggle on an invitation that was deleted meanwhile -> `find_by!(token:)` in
  `set_invitation` raises `ActiveRecord::RecordNotFound`; the existing
  `Admin::ApplicationController` error handling applies (unchanged behaviour
  from today's dropdown).

## Testing

- Controller specs (`spec/controllers/admin/workshops_controller_spec.rb`):
  - `GET #rsvp` without a search term renders and executes no invitations
    query (assert via query counter).
  - `GET #rsvp` with a search term returns only matching invited members, is
    paginated, and eager-loads member (no per-row queries).
  - Banned members are excluded from results.
  - Non-organiser/admin is not authorised.
- Request/controller spec on the existing `update` action: toggling
  `attending` still works via the post-from-rsvp-page path (the update logic
  itself is already covered; add an explicit assert that a PUT with the
  inverted value flips `attending` and redirects back).
- View assertion: workshop show page no longer renders a `select` of
  invitations.

## Out of scope

- Searching / inviting members who have no invitation row (pool B) — future
  work.
- AJAX typeahead — the search form is a plain GET, matching the rest of admin.
- Removing the dropdown-related code from Chosen initialisation elsewhere.

## Success criteria

- `/admin/workshops/:id` show no longer queries `invitations` (faster, fewer
  allocations — the dropdown was the remaining view-time cost).
- `/admin/workshops/:id/rsvp` shows the eligible invited-member count on load
  (single COUNT query), loads no member rows until a search is submitted, and
  results are paginated at 20.
- Toggling a member's RSVP state works in both directions and returns the
  organiser to the search context.