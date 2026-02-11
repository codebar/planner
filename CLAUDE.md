# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

codebar planner is a Rails 8.1 application for managing [codebar.io](https://codebar.io) members and events. It handles workshop/event scheduling, member registration, invitations, RSVPs, and feedback collection for coding workshops organized by codebar chapters.

## Development Setup

**IMPORTANT**: Always use native installation with `bundle exec` commands. Never use Docker or `bin/d*` commands.

### Native Installation

- **Setup**: `bundle && rake db:create db:migrate db:seed`
- **Server**: `bundle exec rails server`
- **Tests**: `bundle exec rspec [path]` - runs RSpec tests, optionally for specific file/line
- **Rails console**: `bundle exec rails console`
- **Run rake tasks**: `bundle exec rake [task]`
- **Linting**: `bundle exec rubocop`

### Docker Setup (Not Used)

Docker setup exists in this repository (`bin/d*` commands) but is **not used** for development work with Claude Code.

### Environment Variables

Required in `.env` file:
```
GITHUB_KEY=<your_github_oauth_client_id>
GITHUB_SECRET=<your_github_oauth_client_secret>
```

Create GitHub OAuth app at https://github.com/settings/applications/new with callback URL `http://localhost:3000/auth/github`.

## Development Workflow

**IMPORTANT**: All changes to this project must be made via pull requests. Never commit directly to the `master` branch.

1. Create a feature branch from `master`
2. Make your changes and commit them to the feature branch
3. Push the branch and create a pull request
4. Wait for review and approval before merging

## Architecture & Domain Model

### Core Domain Concepts

**Members**: Users of the system. Can be students, coaches, both, or neither. Authenticated via GitHub OAuth (stored in `auth_services` table). Members have roles managed by Rolify (`admin`, `organiser` for chapters/workshops).

**Chapters**: Local codebar organizations (e.g., "London", "Berlin"). Chapters have organisers and host workshops/events.

**Workshops**: Regular coding workshops. Belong to one chapter. Send invitations to chapter subscribers. Attendance is first-come-first-served up to venue capacity, with automatic waiting list management.

**Events**: Multi-chapter events. Attendance requires admin verification/approval after RSVP.

**Sponsors**: Organizations providing venue space. Have addresses and member contacts. One sponsor acts as "host" (venue) for each workshop.

**Invitations**: Track member attendance status for workshops/events. Different classes:
- `WorkshopInvitation` - for workshops (auto-accepted up to capacity)
- `Invitation` - for events (require admin verification)

**Waiting Lists**: When workshops are full, members can join waiting list (`WaitingList` model with `auto_rsvp` flag). Automatically promoted when spaces become available.

### Key Model Relationships

```
Chapter
  has_many :workshops
  has_many :groups (for subscriptions)
  has_many :organisers (via permissions)

Workshop
  belongs_to :chapter
  has_many :workshop_sponsors
  has_many :invitations (WorkshopInvitation)
  has_one :host (sponsor where workshop_sponsors.host = true)

Member
  has_many :workshop_invitations
  has_many :invitations (for events)
  has_many :subscriptions
  has_many :groups, through: :subscriptions
  has_many :chapters, through: :groups
  has_many :auth_services

Sponsor
  has_one :address
  has_many :workshop_sponsors
  has_many member_contacts
```

See `app/models/README.md` for detailed data model documentation.

## Authorization & Authentication

- **Authentication**: GitHub OAuth via OmniAuth. Session stores `member_id`.
- **Authorization**: Pundit policies in `app/policies/`. Key roles:
  - `admin` - global admin access
  - `organiser` - per-chapter or per-workshop organiser role
- Access checks: `current_user.is_admin?`, `current_user.manager?` (admin or organiser)
- Policies must be called in controllers. `ApplicationController` rescues `Pundit::NotAuthorizedError`.

## Frontend Stack

- **CSS Framework**: Bootstrap 5
- **JavaScript**: Stimulus controllers, Turbo for page transitions
- **View Engine**: HAML (not ERB)
- **Asset Pipeline**: Sprockets with importmap-rails
- **Icons**: Font Awesome 5

## Background Jobs

- **Queue**: Delayed Job (database-backed)
- Jobs defined in `app/jobs/` (inheriting from `ApplicationJob`)
- Worker process: `bin/delayed_job start` (native) or managed by Docker

## Testing

- **Framework**: RSpec with Capybara for feature tests
- **JavaScript Driver**: Playwright (Chromium by default)
- **Factories**: Fabrication (not FactoryBot)
- **Test data**: Faker for generated data
- **Coverage**: SimpleCov
- **JavaScript tests**: Capybara with Playwright driver
  - Use `PLAYWRIGHT_HEADLESS=false` to debug with visible browser
  - Use `PWDEBUG=1` for Playwright Inspector (step-through debugging)
  - Use `PLAYWRIGHT_BROWSER=firefox` or `webkit` for cross-browser testing
- **Matchers**: Shoulda Matchers, RSpec Collection Matchers

Run single test: `bin/drspec spec/path/to/file_spec.rb:42`

## Code Style

- **Linter**: RuboCop with custom config (`.rubocop.yml`)
- **Max line length**: 120 characters
- **Max method length**: 10 lines (excludes tests)
- **Hash syntax**: Modern style `{ key: value }` not `{ :key => value }`
- **HAML linting**: `haml_lint` (config in `.haml-lint.yml`)
- Run linter: `rubocop` or `bin/drubocop` (Docker)

Key RuboCop exclusions:
- `db/`, `spec/`, `config/`, `bin/` excluded from most cops
- Documentation not required (`Style/Documentation: false`)

## Parameter Handling

This application uses Rails 8.0 `params.expect` for parameter filtering and validation.

### Basic Pattern

Use `params.expect` instead of `params.require().permit()`:

```ruby
def resource_params
  params.expect(resource: [
    :field1, :field2, :field3
  ])
end
```

### Type Safety

Controllers using `params.expect` raise `ActionController::ParameterMissing` when:
- Parameter type is tampered (e.g., string sent instead of hash)
- Required parameters are missing
- Nested parameter structure is invalid

This makes parameter validation failures explicit and easier to handle at the application level.

### Nested Arrays

Use hash syntax for array parameters:

```ruby
params.expect(workshop: [
  :name, :date,
  { sponsor_ids: [] }
])
```

### Nested Attributes

**IMPORTANT:** `params.expect` does NOT work with `accepts_nested_attributes_for`.

Rails forms with nested attributes send hash-with-numeric-keys like `{'0' => {...}, '1' => {...}}`, which params.expect cannot handle. For controllers using `accepts_nested_attributes_for`, continue using the old syntax:

```ruby
# Use require().permit() for nested attributes
params.require(:sponsor).permit(
  :name, :website,
  address_attributes: [:id, :street, :city, :postal_code],
  contacts_attributes: [:id, :name, :email, :_destroy]
)
```

Note: `_destroy` is permitted like any other field for deletion.

### Conditional Parameters

When parameters are optional:

```ruby
def index
  search_params = if params.key?(:member_search)
                    params.expect(member_search: [:name, :callback_url])
                  else
                    {}
                  end
  # use search_params
end
```

### Return Value

`params.expect(key: [...])` returns the **inner permitted parameters**, not wrapped:

```ruby
result = params.expect(member: [:name, :email])
# Access as: result[:name], NOT result[:member][:name]
```

### Testing

Controller specs should verify parameter filtering works:

```ruby
it 'filters unpermitted parameters' do
  post :create, params: { resource: valid_attrs, hacker_field: 'malicious' }
  expect(response).to be_successful # hacker_field is filtered out
end
```


## Important Patterns

### Controllers

- Use Pundit `authorize` to check permissions
- Admin controllers in `app/controllers/admin/` namespace
- Super admin controllers in `app/controllers/super_admin/`
- Use `authenticate_admin!` or `authenticate_admin_or_organiser!` before_action for protected routes

### Models

- Concerns in `app/models/concerns/` (e.g., `Invitable`, `Listable`, `DateTimeConcerns`)
- Permissions via Rolify: `member.add_role(:organiser, workshop)`
- Scopes commonly used for filtering (e.g., `Member.not_banned`, `Workshop.students`)

### Views

- Use Presenters (`app/presenters/`) for complex view logic
- Form objects in `app/form_models/` for complex forms
- Helpers in `app/helpers/`

### Services

- Service objects in `app/services/` for complex business logic
- Example: invitation management, email sending logic

## Routes

- Root: `dashboard#show`
- Admin namespace: `/admin/*` - requires admin/organiser access
- Auth: `/auth/github` (login), `/logout` (logout)
- Key resources: `/workshops/:id`, `/events/:id`, `/meetings/:id`
- Chapter pages: `/:id` (catch-all at end of routes)

## Database

- **RDBMS**: PostgreSQL
- **Migrations**: Standard Rails migrations in `db/migrate/`
- **Seeds**: `db/seeds.rb` creates sample data for development

## Deployment

This app uses Heroku. See `Makefile` for deployment commands (requires appropriate Heroku access):
- `make deploy_production`
- `make deploy_staging`

## Additional Tools

- **Email preview**: Letter Opener (development) - emails open in browser
- **Error tracking**: Rollbar (production)
- **Performance monitoring**: Scout APM
- **Activity tracking**: PublicActivity gem for user action history
- **Pagination**: Pagy
- **File uploads**: CarrierWave (AWS S3 in production)
- **Friendly URLs**: FriendlyId for slug generation
