# Workshop "RSVP members" Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 4,000-item RSVP dropdown on the admin workshop show page with a dedicated, search-driven "RSVP members" page where organisers search invited members by name and toggle their RSVP state.

**Architecture:** A new member route (`GET /admin/workshops/:id/rsvp`) on `Admin::WorkshopsController` renders a view that shows the eligible invited-member count, a name-search form, and paginated (Pagy, 20/page) results for the workshop's invited members (any invitation state — attending, pending, declined). Each result row posts the inverted `attending` value to the **existing** `Admin::InvitationsController#update`, which already handles both directions (email, waiting-list removal, `redirect_back`). The show page's `<select>` is replaced by a link to the new page.

**Tech Stack:** Rails 8.1, HAML, Bootstrap 5, Pagy (existing `shared/pagination` partial), RSpec + Fabrication.

## Global Constraints

- Branch from `fix/admin-workshop-nplus1` (PR #2797 is not yet merged): the `count_queries` test helper and the capped `recent_invites` dropdown block this plan relies on exist on that branch, not on `master`. Create the feature branch from that branch's tip.
- HAML for views; no new CSS abstractions; Bootstrap 5 classes.
- No JavaScript; plain GET (search) and PUT (toggle) forms.
- Mutations MUST go through the existing `Admin::InvitationsController#update` — do not add new mutation logic.
- Search pool = members with an invitation row for this workshop, excluding banned (`Member.not_banned`). No invitation creation.
- Pagination via the standard `pagy(scope, items: 20)` helper and `shared/pagination` partial, matching `Admin::GroupsController#show`.
- RuboCop clean, max line length 120. TDD: write failing spec, verify red, implement, verify green, commit.
- Work in the existing worktree/branch for this feature; never commit to `master`.

---

## File Structure

- Modify: `config/routes.rb` — add `get 'rsvp'` member route in the admin `resources :workshops` block (next to `get 'changes'`).
- Modify: `app/controllers/admin/workshops_controller.rb` — add `rsvp` action, `paginate_matching_invitations` helper, and `rsvp` to the `set_workshop_by_id` before_action.
- Create: `app/views/admin/workshops/rsvp.html.haml` — search form, eligible count, results table with toggle forms, pagination.
- Modify: `app/views/admin/workshops/_invitation_management.html.haml` — replace the `<select>` form with an "RSVP a member" link.
- Modify: `spec/controllers/admin/workshops_controller_spec.rb` — specs for `GET #rsvp`, toggle redirect, and show-page assertions.
- Test: `spec/queriers` — none (no query object needed).

---

### Task 1: `rsvp` route and controller action

**Files:**
- Modify: `config/routes.rb` (admin `resources :workshops` block, ~line 145-157)
- Modify: `app/controllers/admin/workshops_controller.rb`
- Test: `spec/controllers/admin/workshops_controller_spec.rb`

**Interfaces:**
- Consumes: the admin member-route param `params[:workshop_id]` (sets `@workshop`); `Member.not_banned` scope; `Member.find_members_by_name(name)` (public class method, ILIKE on `CONCAT(name,' ',surname)`); `pagy(scope, items:)` helper.
- Produces: `Admin::WorkshopsController#rsvp` — assigns `@workshop`, `@eligible_count` (Integer, always), and `@pagy`/`@invitations` (only when `params[:q]` present; `@invitations` is a Pagy-page of `WorkshopInvitation` with `member` eager-loaded).

- [ ] **Step 1: Write the failing controller specs**

Add to `spec/controllers/admin/workshops_controller_spec.rb`, inside the existing `describe` blocks (the file already has `workshop`, `admin`, and `login_as_organiser(admin, workshop.chapter)` in `before`):

```ruby
describe 'GET #rsvp' do
  let(:member) { Fabricate(:member, name: 'Zoe', surname: 'Searchable') }
  let!(:matching) { Fabricate(:workshop_invitation, workshop: workshop, member: member, attending: nil) }
  let!(:other_member) { Fabricate(:member, name: 'Aaron', surname: 'Other') }
  let!(:other) { Fabricate(:workshop_invitation, workshop: workshop, member: other_member, attending: true) }
  let!(:banned_member) { Fabricate(:member, name: 'Bob', surname: 'Banned') }
  let!(:banned_invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: banned_member, attending: nil) }

  before do
    Fabricate(:ban, member: banned_member)
    Fabricate(:workshop_invitation, member: matching) # an invite for a DIFFERENT workshop
  end

  it 'is not accessible without organiser rights' do
    allow(controller).to receive(:manager?).and_return(false)
    get :rsvp, params: { workshop_id: workshop.id }

    expect(response).to redirect_to(root_path)
  end

  it 'assigns the eligible count and no invitations when no search term is given' do
    get :rsvp, params: { workshop_id: workshop.id }

    expect(assigns(:eligible_count)).to eq(2) # matching + other; banned is excluded from the count
    expect(assigns(:invitations)).to be_nil
    expect(response).to have_http_status(:success)
  end

  it 'returns only matching invited members for the workshop, excluding banned members' do
    get :rsvp, params: { workshop_id: workshop.id, q: 'Zoe' }

    expect(assigns(:invitations).map(&:id)).to eq([matching.id])
  end

  it 'excludes banned members from search results' do
    get :rsvp, params: { workshop_id: workshop.id, q: 'Banned' }

    expect(assigns(:invitations)).to be_empty
  end

  it 'filters by member name case-insensitively across first and surname' do
    get :rsvp, params: { workshop_id: workshop.id, q: 'SEARCHA' }

    expect(assigns(:invitations).map(&:id)).to eq([matching.id])
  end

  it 'eager loads member so rendering does not query per row' do
    query_count = count_queries { get :rsvp, params: { workshop_id: workshop.id, q: 'Zoe' } }

    expect(query_count).to be < 8
  end
end
```

Note: `manager?` (login + admin/organiser) is the existing guard in `ApplicationController#authenticate_admin_or_organiser!`, so stubbing it to false reproduces the unauthorised redirect the admin layer already uses. `count_queries` is already defined in this spec file on the `fix/admin-workshop-nplus1` branch (added in PR #2797) — do not re-add it.

- [ ] **Step 2: Run the specs to verify they fail**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -e "GET #rsvp"`
Expected: FAIL — `ActionController::UrlGenerationError` (no route) and `The action 'rsvp' could not be found`.

- [ ] **Step 3: Add the route**

In `config/routes.rb`, inside the admin block `resources :workshops, except: [:index] do ... end` (next to `get 'changes'`):

```ruby
      get 'rsvp'
```

Verify: `bundle exec rails routes | grep admin_workshop_rsvp` → `admin_workshop_rsvp GET /admin/workshops/:workshop_id/rsvp`.

Note: like the other member routes in this block (`changes`, `attendees_checklist`), the admin `resources :workshops` block binds the workshop segment as `:workshop_id` — NOT `:id`. So the action must read `params[:workshop_id]`.

- [ ] **Step 4: Implement the controller action**

In `app/controllers/admin/workshops_controller.rb`, add the action and private helper (place the action near the other public actions; the helper in the private section):

```ruby
  def rsvp
    @workshop = Workshop.find(params[:workshop_id])
    authorize @workshop, :update?

    @eligible_count = @workshop.invitations
                               .joins(:member)
                               .merge(Member.not_banned)
                               .count

    return unless params[:q].present?

    @pagy, @invitations = paginate_matching_invitations(params[:q])
  end
```

```ruby
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

Note: do **not** use the `set_workshop_by_id` before_action (it reads `params[:id]`, which the member route does not provide). Load `@workshop` from `params[:workshop_id]` inside the action, keeping it undecorated so Pundit still resolves `WorkshopPolicy`. `authorize @workshop, :update?` uses the existing `WorkshopPolicy#update?` (`admin_or_chapter_organiser?`); no new policy method needed.

- [ ] **Step 5: Create a minimal placeholder view**

Create `app/views/admin/workshops/rsvp.html.haml` with just:

```haml
%p RSVP members
```

(The full view is Task 2.) This makes the controller-rendered response succeed.

- [ ] **Step 6: Run the specs to verify they pass**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -e "GET #rsvp"`
Expected: all `GET #rsvp` examples pass.

- [ ] **Step 7: Run the full file + lint**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb`
Expected: all pass (existing examples plus new ones).
Run: `bundle exec rubocop app/controllers/admin/workshops_controller.rb spec/controllers/admin/workshops_controller_spec.rb`
Expected: no offenses.

- [ ] **Step 8: Commit**

```bash
git add config/routes.rb app/controllers/admin/workshops_controller.rb app/views/admin/workshops/rsvp.html.haml spec/controllers/admin/workshops_controller_spec.rb
git commit -m "feat: add admin workshop RSVP page route and action"
```

---

### Task 2: `rsvp` view with search, count, toggle, pagination

**Files:**
- Modify: `app/views/admin/workshops/rsvp.html.haml`
- Modify: `spec/controllers/admin/workshops_controller_spec.rb`

**Interfaces:**
- Consumes: `@workshop` (Workshop), `@eligible_count` (Integer), `@pagy` (Pagy), `@invitations` (Pagy page of WorkshopInvitation with `member` loaded, may be nil); route helpers `admin_workshop_rsvp_path(@workshop)`, `admin_workshop_path(@workshop)`, `admin_member_path(member)`, `admin_workshop_invitation_path(@workshop, invitation)`; `shared/pagination` partial; existing `Admin::InvitationsController#update` (PUT with `attending` param).
- Produces: rendered HTML — the complete page.

- [ ] **Step 1: Write a failing view-level controller spec**

Add to the rsvp describe block in `spec/controllers/admin/workshops_controller_spec.rb`:

```ruby
  it 'renders the eligible count, search box, back link and toggle forms' do
    get :rsvp, params: { workshop_id: workshop.id, q: 'Zoe' }

    expect(response.body).to include('invited members')
    expect(response.body).to include('Search')
    expect(response.body).to include('Back to')
    # q: 'Zoe' only returns `matching` (attending: nil) -> its button says 'RSVP'
    expect(response.body).to include('RSVP')
    expect(response.body).not_to include('Mark as not attending')
  end

  it 'renders the not-attending toggle for an already-attending result' do
    get :rsvp, params: { workshop_id: workshop.id, q: 'Aaron' }

    expect(response.body).to include('Mark as not attending')
  end
```

Add the toggle mutation example to **`spec/controllers/admin/invitations_controller_spec.rb`** (create the file if it does not exist), NOT the workshops controller — `put :update` must dispatch to `Admin::InvitationsController#update`, which is where the toggle routes live:

```ruby
RSpec.describe Admin::InvitationsController, type: :controller do
  let!(:workshop) { Fabricate(:workshop) }
  let(:admin) { Fabricate(:member) }
  let(:member) { Fabricate(:member, name: 'Zoe', surname: 'Searchable') }
  let!(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member, attending: nil) }

  before { login_as_organiser(admin, workshop.chapter) }

  describe 'PUT #update (RSVP toggle from the rsvp page)' do
    it 'marks an invitation attending and redirects back to the rsvp page' do
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)
      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'true' }

      expect(invitation.reload.attending).to be(true)
      expect(response).to redirect_to(admin_workshop_rsvp_url(workshop))
    end

    it 'marks an attending invitation as not attending' do
      invitation.update!(attending: true)
      request.env['HTTP_REFERER'] = admin_workshop_rsvp_url(workshop)
      put :update, params: { workshop_id: workshop.id, id: invitation.token, attending: 'false' }

      expect(invitation.reload.attending).to be(false)
      expect(response).to redirect_to(admin_workshop_rsvp_url(workshop))
    end
  end
end
```

Note: `admin_workshop_invitation_path(@workshop, invitation)` (two args) resolves to the plural `resources :invitations, only: [:update]` route, so `params[:id]` is the invitation token (via `Invitation#to_param`) and `set_invitation` finds it with `@workshop.invitations.find_by!(token: invitation_id)`; `invitation_id` reads `params[:id]` when there is no `:workshop` key (there isn't — the toggle posts `attending` only). `update`'s non-XHR branch `redirect_back`s to the Referer (the rsvp page), preserving search + page.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -e "rsvp" `
Expected: FAIL — view only renders "RSVP members" placeholder; strings like `invited members` not present.

- [ ] **Step 3: Implement the full view**

Replace the placeholder `app/views/admin/workshops/rsvp.html.haml` with:

```haml
.container.py-4.py-lg-5
  .row.mb-3
    .col
      = link_to 'Back to workshop', admin_workshop_path(@workshop), class: 'text-muted'
      %h2.mt-2 RSVP members
      %p.text-muted
        #{number_with_delimiter(@eligible_count)} invited members (total)

  .row.mb-4
    .col.col-md-10.col-lg-8
      = form_tag admin_workshop_rsvp_path(@workshop), method: :get, class: 'row g-3 align-items-end' do
        .col-auto.col-md-6
          = label_tag :q, 'Member name', class: 'form-label'
          = text_field_tag :q, params[:q], placeholder: 'Enter member name', class: 'form-control'
        .col-auto
          = submit_tag 'Search', class: 'btn btn-primary'

  - if params[:q].present?
    .row
      .col.col-md-10.col-lg-8
        - if @invitations.empty?
          %p.text-muted No members found for "#{params[:q]}".
        - else
          %table.table.table-hover
            %thead
              %tr
                %th Member
                %th Role
                %th Status
                %th
            %tbody
              - @invitations.each do |invitation|
                %tr
                  %td
                    = link_to invitation.member.full_name, admin_member_path(invitation.member)
                    %br
                    %small.text-muted= invitation.member.email
                  %td= invitation.role
                  %td
                    - if invitation.attending?
                      %span.badge.bg-success Attending
                    - elsif invitation.attending == false
                      %span.badge.bg-secondary Not attending
                    - else
                      %span.badge.bg-warning No response
                  %td
                    = form_tag admin_workshop_invitation_path(@workshop, invitation), method: :put, class: 'd-inline' do
                      = hidden_field_tag :attending, invitation.attending? ? 'false' : 'true'
                      = submit_tag(invitation.attending? ? 'Mark as not attending' : 'RSVP', class: 'btn btn-sm btn-outline-primary', aria: { label: "#{invitation.member.full_name} \u2014 #{invitation.attending? ? 'mark as not attending' : 'RSVP'}" })
          = render partial: 'shared/pagination', locals: { pagy: @pagy, model: 'invitation' } if @pagy&.pages&.positive?
  - else
    %p.text-muted Search for a member to manage their RSVP.
```

Notes:
- `@invitations` is only assigned when `params[:q]` is present (Task 1), so the `if params[:q].present?` guard matches. Use `@invitations.empty?` for the no-match message (Pagy returns an array).
- The toggle form posts `attending` as the string `'true'`/`'false'` (hidden field) — `update_to_attending` compares `attending.eql?('true')`.
- `admin_workshop_invitation_path(@workshop, invitation)` renders `/admin/workshops/:workshop_id/invitations/:token` (the plural `resources :invitations, only: [:update]` route; `:id` = token via `to_param`). `update`'s non-XHR branch `redirect_back`s, returning to the rsvp page with search + page preserved.

- [ ] **Step 4: Run the specs to verify they pass**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -e "rsvp" -e "GET #rsvp"`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add app/views/admin/workshops/rsvp.html.haml spec/controllers/admin/workshops_controller_spec.rb
git commit -m "feat: render RSVP members page with search, count and toggle"
```

---

### Task 3: Replace the dropdown on the show page with a link

**Files:**
- Modify: `app/views/admin/workshops/_invitation_management.html.haml`
- Modify: `spec/controllers/admin/workshops_controller_spec.rb`

**Interfaces:**
- Consumes: `@workshop`, `admin_workshop_rsvp_path(@workshop)` (from Task 1).
- Produces: show page with the "RSVP a member" link and no invitation `<select>`.

- [ ] **Step 1: Write a failing spec asserting the dropdown is gone**

Add to the `GET #show` describe block in `spec/controllers/admin/workshops_controller_spec.rb`:

```ruby
  it 'links to the RSVP members page instead of rendering an invitations select' do
    Fabricate(:workshop_invitation, workshop: workshop, attending: nil)
    get :show, params: { id: workshop.id }

    expect(response.body).to include(admin_workshop_rsvp_path(workshop))
    expect(response.body).not_to include('chosen-select')
    expect(response.body).not_to include('outstanding invitations')
  end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -e "GET #show"`
Expected: FAIL — the current page includes `chosen-select` and no link to the rsvp page.

- [ ] **Step 3: Replace the select block**

In `app/views/admin/workshops/_invitation_management.html.haml`, **delete** the entire `= simple_form_for :workshop, url: admin_workshop_invitations_path(@workshop, attending: true) ... do |f| ... end` block (the one containing `f.select :invitations`, `recent_invites`, and the "outstanding invitations" caption added in PR #2797). Replace it with:

```haml
.link-to-rsvp.mb-4
  = link_to 'RSVP a member', admin_workshop_rsvp_path(@workshop), class: 'btn btn-sm btn-outline-primary'
```

Keep the surrounding structure (the counts paragraph and the `See all invitations' statuses` link) unchanged.

- [ ] **Step 4: Run the specs to verify they pass**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb`
Expected: all pass (including the new rsvp specs from Tasks 1-2 and the dropdown-removal assertion).

- [ ] **Step 5: Lint and full suite**

Run:
- `bundle exec rubocop app/controllers/admin/workshops_controller.rb spec/controllers/admin/workshops_controller_spec.rb`
- `bundle exec rspec spec/controllers/ spec/requests/`
Expected: no offenses; all controller/request specs green.

- [ ] **Step 6: Commit**

```bash
git add app/views/admin/workshops/_invitation_management.html.haml spec/controllers/admin/workshops_controller_spec.rb
git commit -m "feat: replace admin workshop RSVP dropdown with link to RSVP page"
```

---

### Task 4: End-to-end verification against production data

**Files:** none (verification only).

- [ ] **Step 1: Run any remaining full suites**

Run: `bundle exec rspec spec/`
Expected: green.

- [ ] **Step 2: Manual check against the production dump**

With the server running against `codebar_production_dump`:
1. `GET /admin/workshops/3824` — confirm the "RSVP a member" link renders and the page body contains no `chosen-select`.
2. `GET /admin/workshops/3824/rsvp` — confirm it loads fast (one COUNT query), shows the eligible count, and shows no member rows until a name is searched.
3. Search "Morgan" — confirm one result, paged at 20, with an RSVP/toggle button; toggling redirects back and flips attendance (check in the DB).