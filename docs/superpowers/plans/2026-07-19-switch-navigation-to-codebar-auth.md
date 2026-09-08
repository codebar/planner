# Switch navigation and auth redirects to `/auth/codebar` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Route all user-facing sign-in flows to `/auth/codebar` instead of `/auth/github`.

**Architecture:** Reuse the existing `ApplicationController#redirect_path` helper for the navigation and terms page links, change the helper to return the new auth path, and update the remaining hardcoded redirects in controllers and their specs.

**Tech Stack:** Rails 8.1, HAML, RSpec, RuboCop.

## Branch

Create the feature branch from `master` before starting work:

```bash
git checkout -b feature/switch-auth-to-codebar
```

## Global Constraints
- No new constants, helpers, or routes.
- All `/auth/github` strings in the auth flow must become `/auth/codebar`.
- `AuthServicesController#destroy` is intentionally left unchanged (it overrides `redirect_path` to `:services`).
- Follow the repo’s Conventional Commits and branch-from-`master` workflow.

---

## File Structure

- `app/controllers/application_controller.rb` — change `redirect_path` return value.
- `app/views/layouts/_navigation.html.haml` — use `redirect_path` helper for Sign in link.
- `app/views/terms_and_conditions/show.html.haml` — use `redirect_path` helper for login link.
- `app/controllers/auth_services_controller.rb` — change `/login` redirect string.
- `app/controllers/terms_and_conditions_controller.rb` — change unauthenticated POST redirect string.
- `spec/controllers/auth_services_controller_spec.rb` — update redirect expectations.

---

### Task 1: Update the central redirect helper

**Files:**
- Modify: `app/controllers/application_controller.rb:111-112`
- Test: `spec/controllers/auth_services_controller_spec.rb` (indirectly), plus any controller specs that exercise `authenticate_member!` or `AuthSessionsController#create`

**Interfaces:**
- Consumes: nothing
- Produces: `ApplicationController#redirect_path` returns `'/auth/codebar'`

- [ ] **Step 1: Change the helper return value**

```ruby
  helper_method :redirect_path
  def redirect_path
    '/auth/codebar'
  end
```

- [ ] **Step 2: Run the auth services controller specs**

Run: `bundle exec rspec spec/controllers/auth_services_controller_spec.rb`
Expected: 2 passes (controller still uses the hardcoded `/auth/github` path at this stage)

- [ ] **Step 3: Commit**

```bash
git add app/controllers/application_controller.rb
git commit -m "feat: redirect unauthenticated users to /auth/codebar"
```

---

### Task 2: Update navigation and terms page links

**Files:**
- Modify: `app/views/layouts/_navigation.html.haml:46`
- Modify: `app/views/terms_and_conditions/show.html.haml:18`
- Test: existing feature/request specs that render the navigation or terms page

**Interfaces:**
- Consumes: `ApplicationController#redirect_path` (now `/auth/codebar`)
- Produces: both views link to the new auth path

- [ ] **Step 1: Update navigation sign-in link**

```haml
        - if !logged_in?
          %li.nav-item
            = link_to redirect_path, class: 'nav-link border-0' do
              Sign in
```

- [ ] **Step 2: Update terms page login link**

```haml
          = link_to t('terms_and_conditions.login_link_text'), redirect_path
```

- [ ] **Step 3: Run any relevant view/feature specs**

Run: `bundle exec rspec spec/views/layouts/ spec/features/ 2>/dev/null || true`
Expected: no failures related to auth links

- [ ] **Step 4: Commit**

```bash
git add app/views/layouts/_navigation.html.haml app/views/terms_and_conditions/show.html.haml
git commit -m "feat: use codebar auth for sign-in links"
```

---

### Task 3: Update remaining hardcoded redirects

**Files:**
- Modify: `app/controllers/auth_services_controller.rb:7`
- Modify: `app/controllers/terms_and_conditions_controller.rb:16`
- Test: `spec/controllers/auth_services_controller_spec.rb`

**Interfaces:**
- Consumes: nothing
- Produces: `GET /login` and unauthenticated `PATCH /terms_and_conditions` redirect to `/auth/codebar`

- [ ] **Step 1: Update `/login` redirect**

```ruby
    redirect_to '/auth/codebar'
```

- [ ] **Step 2: Update terms POST redirect**

```ruby
      redirect_to '/auth/codebar'
```

- [ ] **Step 3: Update controller specs**

```ruby
      expect(response).to redirect_to("/auth/codebar")
```

```ruby
      expect(response).to redirect_to("/auth/codebar")
```

- [ ] **Step 4: Run the updated controller specs**

Run: `bundle exec rspec spec/controllers/auth_services_controller_spec.rb spec/controllers/terms_and_conditions_controller_spec.rb`
Expected: all pass

- [ ] **Step 5: Commit**

```bash
git add app/controllers/auth_services_controller.rb app/controllers/terms_and_conditions_controller.rb spec/controllers/auth_services_controller_spec.rb
git commit -m "feat: update hardcoded auth redirects to /auth/codebar"
```

---

### Task 4: Verify and lint

**Files:**
- All files modified above

**Interfaces:**
- Consumes: all previous changes
- Produces: clean test and lint output

- [ ] **Step 1: Run the full test suite**

Run: `make test`
Expected: all green

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`
Expected: no offences

- [ ] **Step 3: Run HAML lint**

Run: `bundle exec haml-lint app/views/layouts/_navigation.html.haml app/views/terms_and_conditions/show.html.haml`
Expected: no offences

- [ ] **Step 4: Commit any auto-corrected lint fixes**

```bash
git commit -am "style: lint fixes for auth url changes" || true
```

---

## Self-Review

- **Spec coverage:** every item from the design doc is captured:
  - `ApplicationController#redirect_path` → Task 1
  - Navigation link → Task 2
  - Terms page link → Task 2
  - `/login` redirect → Task 3
  - Terms POST redirect → Task 3
  - Spec updates → Task 3
- **Placeholder scan:** no TBDs, TODOs, or vague instructions.
- **Type consistency:** no new types introduced; all paths are strings.
