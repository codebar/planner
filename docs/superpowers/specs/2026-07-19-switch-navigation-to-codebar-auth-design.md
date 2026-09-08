# Switch navigation and auth redirects to `/auth/codebar`

## Context

The new authentication provider at `/auth/codebar` is now proven and working. The application currently sends users to `/auth/github` in several places, including the navigation sign-in link and other auth entry points.

## Goal

Route all user-facing sign-in flows to `/auth/codebar` instead of `/auth/github`.

## Changes

1. **`ApplicationController#redirect_path`**
   - Return `'/auth/codebar'` instead of `'/auth/github'`.
   - This covers `authenticate_member!` (protected routes) and `AuthSessionsController#create` (`/register`).

2. **`app/views/layouts/_navigation.html.haml`**
   - Replace the hardcoded `/auth/github` sign-in link with the `redirect_path` helper.

3. **`app/views/terms_and_conditions/show.html.haml`**
   - Replace the hardcoded `/auth/github` login link with the `redirect_path` helper.

4. **`AuthServicesController#new`**
   - Change `redirect_to '/auth/github'` to `redirect_to '/auth/codebar'`.

5. **`TermsAndConditionsController#update`**
   - Change `redirect_to '/auth/github'` to `redirect_to '/auth/codebar'`.

6. **`spec/controllers/auth_services_controller_spec.rb`**
   - Update expectations from `/auth/github` to `/auth/codebar`.

## Non-changes

- `AuthServicesController#destroy` calls `redirect_to redirect_path`, but it overrides the helper to return `:services`, so it is unaffected.
- No new constants, helpers, or routes are introduced.

## Verification

- Run the affected controller specs.
- Run RuboCop and HAML lint.
- Smoke-test the navigation sign-in link and `/login` path in development.
