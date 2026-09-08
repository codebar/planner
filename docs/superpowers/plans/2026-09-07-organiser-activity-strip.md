# Organiser Activity Weekly Strip Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record every member, organiser, and relevant admin action in the existing `activities` table, then render a 52-week GitHub-status-style activity strip on the admin member profile.

**Architecture:** Two PRs. PR 1 adds `MemberActivityRecorder` (single funnel writing `PublicActivity::Activity` rows with the acting member as `owner`) and instruments all write sites. PR 2 adds `Admin::Members::ActivityStrip` (one indexed query, ISO-week bucketing, three states) and `Admin::Members::ActivityStripComponent` (SVG bars), rendered on `/admin/members/:id` behind an organiser check.

**Tech Stack:** Rails 8.1, public_activity (already installed — zero schema changes except one `created_by_id` migration), ViewComponent, RSpec + Fabrication, HAML.

**Spec:** `docs/superpowers/specs/2026-09-07-organiser-activity-strip-design.md`

## Global Constraints

- Never work directly on `master`; each PR from its own feature branch. PR 1 from `spec/organiser-activity-strip` is fine to rebranch, or cut fresh.
- Run tests with `bundle exec rspec <path>`; full suite via `bundle exec parallel_rspec spec/ -n 3` before pushing.
- RuboCop clean on touched files: `bundle exec rubocop app spec`.
- Activity recording must never break user flows: recorder rescues persistence errors internally.
- Recorder keys come from the shared `KEYS` vocabulary — new sites add their key to the list and to the spec's assertions.
- All prose/comments American English (documentation), 120-char max line length.
- Fabrication (not FactoryBot), Faker for data.

---

# PR 1 — Instrumentation

### Task 1: MemberActivityRecorder service

**Files:**
- Create: `app/services/member_activity_recorder.rb`
- Test: `spec/services/member_activity_recorder_spec.rb`

**Interfaces:**
- Produces: `MemberActivityRecorder.record(actor:, key:, trackable: nil, recipient: nil)` — creates one `PublicActivity::Activity` row with `owner: actor`; rescues and logs all persistence errors.

- [ ] **Step 1: Write the failing tests**

```ruby
# spec/services/member_activity_recorder_spec.rb
require 'rails_helper'

RSpec.describe MemberActivityRecorder do
  let(:member) { Fabricate(:member) }

  it 'creates an activity row owned by the actor' do
    described_class.record(actor: member, key: 'member.login')

    activity = PublicActivity::Activity.find_by(owner: member)
    expect(activity.key).to eq('member.login')
  end

  it 'stores trackable and recipient' do
    other = Fabricate(:member)

    described_class.record(actor: member, key: 'member.banned', recipient: other)

    activity = PublicActivity::Activity.order(:created_at).last
    expect(activity.recipient).to eq(other)
    expect(activity.trackable).to be_nil
  end

  it 'never raises on persistence failure' do
    allow(PublicActivity::Activity).to receive(:create!)
      .and_raise(ActiveRecord::RecordInvalid)
    allow(Rails.logger).to receive(:warn)

    expect { described_class.record(actor: member, key: 'member.login') }.not_to raise_error
    expect(Rails.logger).to have_received(:warn).with(/MemberActivityRecorder failed/)
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/services/member_activity_recorder_spec.rb`
Expected: FAIL with `NameError: uninitialized constant MemberActivityRecorder`

- [ ] **Step 3: Write the service**

```ruby
# app/services/member_activity_recorder.rb
# frozen_string_literal: true

# Single funnel for member-activity rows on the public_activity `activities` table.
# Explicit call sites only — no model callbacks — so nothing is double-logged.
# Recording is observability: persistence failures are logged, never raised.
class MemberActivityRecorder
  # Key vocabulary in use; extend when adding sites. New keys classify as :active in the strip.
  KEYS = %w[
    member.login
    member.logout
    member.checked_in
    member_note.created
    member.banned
    profile.updated
    toc.accepted
    auth_service.removed
    subscription.created
    subscription.removed
    subscription.admin_updated
    mailing_list.subscribe
    mailing_list.unsubscribe
    event_invitation.rsvp
    event_invitation.rejected
    meeting_invitation.rsvp
    meeting_invitation.cancelled
    workshop_invitation.rsvp
    workshop_invitation.rejected
    waiting_list.joined
    waiting_list.left
    organiser_role.granted
    organiser_role.revoked
    invitation.send_batch
    invitation.rsvp_override
    invitation.verified
    workshop.created
    meeting_invitation.created
    meeting_invitation.updated
  ].freeze

  def self.record(actor:, key:, trackable: nil, recipient: nil)
    PublicActivity::Activity.create!(owner: actor, key: key, trackable: trackable, recipient: recipient)
  rescue StandardError => e
    Rails.logger.warn("MemberActivityRecorder failed (#{key}): #{e.class}: #{e.message}")
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/services/member_activity_recorder_spec.rb`
Expected: 3 examples, 0 failures

- [ ] **Step 5: Commit**

```bash
git add app/services/member_activity_recorder.rb spec/services/member_activity_recorder_spec.rb
git commit -m 'Add MemberActivityRecorder service'
```

### Task 2: Login capture via `sign_in!` funnel

**Files:**
- Modify: `app/controllers/auth_services_controller.rb`
- Test: `spec/requests/member_login_activity_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).
- Produces: private `AuthServicesController#sign_in!(member, auth_service)` — sets all four session values and records `member.login`. Both `create` branches call it.

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_login_activity_spec.rb
require 'rails_helper'

RSpec.describe 'Member login activity' do
  it 'records member.login on the existing auth service path' do
    member = Fabricate(:member, email: 'existing-login@example.com')
    Fabricate(:auth_service, member: member, provider: 'github', uid: 'login-uid-1')

    mock_auth_hash(provider: 'github', uid: 'login-uid-1', email: member.email)
    post '/auth/github/callback'

    expect(PublicActivity::Activity.exists?(owner: member, key: 'member.login')).to be(true)
  end

  it 'records member.login when the callback creates a new member' do
    mock_auth_hash(provider: 'github', uid: 'brand-new-uid', email: 'fresh-login@example.com')

    expect { post '/auth/github/callback' }
      .to change { PublicActivity::Activity.where(key: 'member.login').count }.by(1)
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_login_activity_spec.rb`
Expected: FAIL — no `member.login` rows exist.

- [ ] **Step 3: Refactor both branches through `sign_in!`**

In `app/controllers/auth_services_controller.rb`, replace the existing-service branch:

```ruby
    elsif current_service
      sign_in!(current_service.member, current_service)

      finish_registration || redirect_to(referer_or_dashboard_path)
```

Replace the new-member branch's four `session[...] =` lines (after the `begin/rescue` block) with:

```ruby
        sign_in!(member, member_service)
```

Add the private method next to `member_from_github_id`:

```ruby
  def sign_in!(member, auth_service)
    session[:member_id]          = member.id
    session[:service_id]         = auth_service.id
    session[:oauth_token]        = omnihash[:credentials][:token]
    session[:oauth_token_secret] = omnihash[:credentials][:secret]

    MemberActivityRecorder.record(actor: member, key: 'member.login')
  end
```

- [ ] **Step 4: Run the new spec and the existing OAuth specs**

Run: `bundle exec rspec spec/requests/member_login_activity_spec.rb spec/requests/auth_services_callback_spec.rb`
Expected: all pass — session behavior unchanged.

- [ ] **Step 5: Commit**

```bash
git add app/controllers/auth_services_controller.rb spec/requests/member_login_activity_spec.rb
git commit -m 'Record member.login through a shared sign_in! funnel'
```

### Task 3: Logout capture

**Files:**
- Modify: `app/controllers/application_controller.rb:105` (`logout!`)
- Test: `spec/requests/member_logout_activity_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_logout_activity_spec.rb
require 'rails_helper'

RSpec.describe 'Member logout activity' do
  it 'records member.logout before clearing the session' do
    member = Fabricate(:member, email: 'logout@example.com')
    Fabricate(:auth_service, member: member, provider: 'github', uid: 'logout-uid-1')
    mock_auth_hash(provider: 'github', uid: 'logout-uid-1', email: member.email)
    post '/auth/github/callback'

    expect { delete '/logout' }
      .to change { PublicActivity::Activity.exists?(owner: member, key: 'member.logout') }
      .from(false).to(true)
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_logout_activity_spec.rb`
Expected: FAIL — no `member.logout` row.

- [ ] **Step 3: Instrument `logout!`**

In `app/controllers/application_controller.rb`, replace:

```ruby
  def logout!
    @current_member = nil
    reset_session
  end
```

with:

```ruby
  def logout!
    member = current_user
    MemberActivityRecorder.record(actor: member, key: 'member.logout') if member
    @current_member = nil
    reset_session
  end
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/member_logout_activity_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/application_controller.rb spec/requests/member_logout_activity_spec.rb
git commit -m 'Record member.logout'
```

### Task 4: Group subscriptions and mailing list

**Files:**
- Modify: `app/controllers/subscriptions_controller.rb` (`create`, `destroy`)
- Modify: `app/controllers/mailing_lists_controller.rb` (`create`, `destroy`)
- Test: `spec/requests/member_activity_subscriptions_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_activity_subscriptions_spec.rb
require 'rails_helper'

RSpec.describe 'Subscription and mailing list activity' do
  let(:member) { Fabricate(:member) }
  let(:group) { Fabricate(:group) }

  before { LoginHelpers::LoginStub.current_user = member }

  after { LoginHelpers::LoginStub.current_user = nil }

  it 'records subscription.created and subscription.removed' do
    post subscriptions_path, params: { subscription: { group_id: group.id } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'subscription.created')).to be(true)

    delete unsubscribe_group_subscription_path(group, member.subscriptions.last)

    expect(PublicActivity::Activity.exists?(owner: member, key: 'subscription.removed')).to be(true)
  end

  it 'records mailing_list.subscribe and unsubscribe' do
    post mailing_lists_path
    expect(PublicActivity::Activity.exists?(owner: member, key: 'mailing_list.subscribe')).to be(true)

    delete mailing_lists_path
    expect(PublicActivity::Activity.exists?(owner: member, key: 'mailing_list.unsubscribe')).to be(true)
  end
end
```

Note: run `bundle exec rails routes | grep -i "subscription\|mailing"` first and substitute the real helper names/paths — the ones above are the expected names but verify against `rails routes` before relying on them.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_activity_subscriptions_spec.rb`
Expected: FAIL — no activity rows. (If route names differ, fix the spec to the real routes; the assertions stay.)

- [ ] **Step 3: Instrument the four actions**

In `app/controllers/subscriptions_controller.rb`, add to `create` immediately after `SubscriptionMailingListService.subscribe(subscription)`:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'subscription.created',
                                    trackable: group)
```

Add to `destroy` immediately after `subscription&.destroy`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'subscription.removed',
                                  trackable: group) if subscription
```

In `app/controllers/mailing_lists_controller.rb`, record as the first line of each action. In `create`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'mailing_list.subscribe')
```

In `destroy`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'mailing_list.unsubscribe')
```

Each action records its own key directly — no request-method inspection.

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/member_activity_subscriptions_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/subscriptions_controller.rb app/controllers/mailing_lists_controller.rb spec/requests/member_activity_subscriptions_spec.rb
git commit -m 'Record subscription and mailing list activity'
```

### Task 5: Profile edits, TOC acceptance, provider unlink

**Files:**
- Modify: `app/controllers/members_controller.rb:25` (`update`)
- Modify: `app/controllers/member/details_controller.rb:17` (`update`)
- Modify: `app/controllers/terms_and_conditions_controller.rb:12` (`update`)
- Modify: `app/controllers/auth_services_controller.rb:76` (`destroy`)
- Test: `spec/requests/member_activity_profile_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_activity_profile_spec.rb
require 'rails_helper'

RSpec.describe 'Profile activity' do
  let(:member) { Fabricate(:member) }

  before { LoginHelpers::LoginStub.current_user = member }

  after { LoginHelpers::LoginStub.current_user = nil }

  it 'records profile.updated on MembersController#update' do
    put member_path(member), params: { member: { about_you: 'updated bio' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'profile.updated')).to be(true)
  end

  it 'records profile.updated on Member::DetailsController#update' do
    put member_details_path(member), params: { member: { about_you: 'details bio' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'profile.updated')).to be(true)
  end

  it 'records toc.accepted' do
    put terms_and_conditions_path, params: { terms_and_conditions_form: { terms: '1' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'toc.accepted')).to be(true)
  end

  it 'records auth_service.removed on provider unlink' do
    service = Fabricate(:auth_service, member: member, provider: 'github', uid: 'unlink-uid-1')

    delete auth_services_path, params: { id: service.id }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'auth_service.removed')).to be(true)
  end
end
```

Note: verify exact route helper names with `bundle exec rails routes | grep -i "member\|terms\|auth_service"` and substitute before running. `Member::DetailsController#update` requires a logged-in member via `require_login` (edit only) — `LoginStub` covers it.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_activity_profile_spec.rb`
Expected: FAIL on the activity assertions (and fix any route-name mismatches first).

- [ ] **Step 3: Instrument the four sites**

In `app/controllers/members_controller.rb#update`, inside the `if @member.update(member_params)` branch, before the `redirect_to`:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'profile.updated')
```

In `app/controllers/member/details_controller.rb#update`, after the `@member.update(attrs)` guard passes (after the newsletter line, before `redirect_to step2_member_path`):

```ruby
    MemberActivityRecorder.record(actor: @member, key: 'profile.updated')
```

In `app/controllers/terms_and_conditions_controller.rb#update`, inside the `valid?` branch after `member.save(validate: false)`:

```ruby
      MemberActivityRecorder.record(actor: member, key: 'toc.accepted')
```

In `app/controllers/auth_services_controller.rb#destroy`, inside the successful-destroy branch before `redirect_to`:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'auth_service.removed',
                                    trackable: service)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/member_activity_profile_spec.rb`
Expected: PASS (4 examples)

- [ ] **Step 5: Commit**

```bash
git add app/controllers/members_controller.rb app/controllers/member/details_controller.rb app/controllers/terms_and_conditions_controller.rb app/controllers/auth_services_controller.rb spec/requests/member_activity_profile_spec.rb
git commit -m 'Record profile update, TOC acceptance, and provider unlink activity'
```

### Task 6: Event and meeting RSVPs (session-authenticated)

**Files:**
- Modify: `app/controllers/invitations_controller.rb` (`attend`, `reject`, `rsvp_meeting`, `cancel_meeting`)
- Test: `spec/requests/member_activity_rsvps_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_activity_rsvps_spec.rb
require 'rails_helper'

RSpec.describe 'Event and meeting RSVP activity' do
  let(:member) { Fabricate(:member) }

  before { LoginHelpers::LoginStub.current_user = member }

  after { LoginHelpers::LoginStub.current_user = nil }

  describe 'event RSVPs' do
    let(:invitation) { Fabricate(:event_invitation, member: member) }

    it 'records event_invitation.rsvp on attend' do
      post attend_event_invitation_path(invitation.token)

      expect(PublicActivity::Activity.exists?(owner: member, key: 'event_invitation.rsvp')).to be(true)
    end

    it 'records event_invitation.rejected on reject' do
      invitation.update!(attending: true)
      post reject_event_invitation_path(invitation.token)

      expect(PublicActivity::Activity.exists?(owner: member, key: 'event_invitation.rejected')).to be(true)
    end
  end

  describe 'meeting RSVPs' do
    let(:invitation) { Fabricate(:meeting_invitation, member: member) }

    it 'records meeting_invitation.rsvp and meeting_invitation.cancelled' do
      post rsvp_meeting_invitation_path(invitation.token)
      expect(PublicActivity::Activity.exists?(owner: member, key: 'meeting_invitation.rsvp')).to be(true)

      post cancel_meeting_invitation_path(invitation.token)
      expect(PublicActivity::Activity.exists?(owner: member, key: 'meeting_invitation.cancelled')).to be(true)
    end
  end
end
```

Note: check fabricator names (`spec/fabricators/`) for event/meeting invitation fabricators and the route helpers via `bundle exec rails routes | grep invitation`; substitute the real ones.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_activity_rsvps_spec.rb`
Expected: FAIL on activity assertions after fixing any fabricator/route names.

- [ ] **Step 3: Instrument the four actions**

In `app/controllers/invitations_controller.rb`:

`#attend`, immediately after `@invitation.update!(attending: true)`:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'event_invitation.rsvp',
                                    trackable: @invitation)
```

`#reject`, immediately after `@invitation.update!(attending: false)`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'event_invitation.rejected',
                                  trackable: @invitation)
```

`#rsvp_meeting`, inside `if invitation.update(attending: true)` before the mailer:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'meeting_invitation.rsvp',
                                    trackable: invitation)
```

`#cancel_meeting`, immediately after `@invitation.update!(attending: false)`:

```ruby
    MemberActivityRecorder.record(actor: @invitation.member, key: 'meeting_invitation.cancelled',
                                  trackable: @invitation)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/member_activity_rsvps_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/invitations_controller.rb spec/requests/member_activity_rsvps_spec.rb
git commit -m 'Record event and meeting RSVP activity'
```

### Task 7: Workshop RSVP and waiting list (token-authenticated)

**Files:**
- Modify: `app/controllers/workshop_invitation_controller.rb` (`accept`, `reject`)
- Modify: `app/controllers/waiting_lists_controller.rb` (`create`, `destroy`)
- Test: `spec/requests/member_activity_token_rsvps_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).
- Constraint: these paths have no `current_user` — the actor is `@invitation.member`, passed explicitly.

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/member_activity_token_rsvps_spec.rb
require 'rails_helper'

RSpec.describe 'Token-based workshop RSVP activity' do
  let(:invitation) { Fabricate(:workshop_invitation) }
  let(:member) { invitation.member }

  it 'records workshop_invitation.rsvp on accept' do
    put workshop_invitation_path(invitation.token), params: { invitation: { attending: 'true' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'workshop_invitation.rsvp')).to be(true)
  end

  it 'records workshop_invitation.rejected on reject' do
    invitation.update!(attending: true)
    put reject_workshop_invitation_path(invitation.token)

    expect(PublicActivity::Activity.exists?(owner: member, key: 'workshop_invitation.rejected')).to be(true)
  end

  it 'records waiting_list.joined and waiting_list.left' do
    post invitation_waiting_lists_path(invitation.token)
    expect(PublicActivity::Activity.exists?(owner: member, key: 'waiting_list.joined')).to be(true)

    delete invitation_waiting_lists_path(invitation.token)
    expect(PublicActivity::Activity.exists?(owner: member, key: 'waiting_list.left')).to be(true)
  end
end
```

Note: verify fabricator (`workshop_invitation`) and token route helpers with `bundle exec rails routes | grep -i "invitation\|waiting"`; substitute the real names. `accept` requires `workshop.rsvp_available?` — fabricate the workshop with a future `date_and_time` and `rsvp_closes_at` so RSVP is open.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/member_activity_token_rsvps_spec.rb`
Expected: FAIL on activity assertions after fixing names/fabrication.

- [ ] **Step 3: Instrument the four actions**

In `app/controllers/workshop_invitation_controller.rb`, in `accept`, inside the `if @invitation.update(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))` branch before the email:

```ruby
      MemberActivityRecorder.record(actor: @invitation.member, key: 'workshop_invitation.rsvp',
                                    trackable: @invitation)
```

In `reject`, immediately after `@invitation.update!(attending: false)`:

```ruby
        MemberActivityRecorder.record(actor: @invitation.member, key: 'workshop_invitation.rejected',
                                      trackable: @invitation)
```

In `app/controllers/waiting_lists_controller.rb`, in `create` after `@invitation.save && WaitingList.add(@invitation, auto_rsvp)` (record unconditionally — the attempt is signal):

```ruby
    MemberActivityRecorder.record(actor: @invitation.member, key: 'waiting_list.joined',
                                  trackable: @invitation)
```

In `destroy` after the `.destroy` call:

```ruby
    MemberActivityRecorder.record(actor: @invitation.member, key: 'waiting_list.left',
                                  trackable: @invitation)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/member_activity_token_rsvps_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/workshop_invitation_controller.rb app/controllers/waiting_lists_controller.rb spec/requests/member_activity_token_rsvps_spec.rb
git commit -m 'Record token-based workshop RSVP and waiting list activity'
```

### Task 8: Organiser role grant/revoke and bans (admin)

**Files:**
- Modify: `app/controllers/admin/chapters/organisers_controller.rb` (`create`, `destroy`)
- Modify: `app/controllers/admin/bans_controller.rb` (`create`)
- Test: `spec/controllers/admin/activity_admin_actions_spec.rb` (create)

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing controller spec**

```ruby
# spec/controllers/admin/activity_admin_actions_spec.rb
require 'rails_helper'

RSpec.describe 'Admin action activity' do
  let(:admin) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }

  before do
    admin.add_role(:admin)
    LoginHelpers::LoginStub.current_user = admin
  end

  after { LoginHelpers::LoginStub.current_user = nil }

  describe 'organiser role changes' do
    let(:member) { Fabricate(:member) }

    it 'records organiser_role.granted on create' do
      post :create, params: {
        chapter_id: chapter.id, organiser: { organiser: member.id }
      }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'organiser_role.granted',
                                              recipient: member)).to be(true)
    end

    it 'records organiser_role.revoked on destroy' do
      member.add_role(:organiser, chapter)

      delete :destroy, params: { chapter_id: chapter.id, id: member.id }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'organiser_role.revoked',
                                              recipient: member)).to be(true)
    end
  end

  describe 'bans' do
    let(:member) { Fabricate(:member) }

    it 'records member.banned' do
      expect do
        post :create, params: {
          member_id: member.id, ban: { reason: 'spam', explanation: 'test', permanent: '1' }
        }
      end.to change { PublicActivity::Activity.exists?(owner: admin, key: 'member.banned',
                                                       recipient: member) }.from(false).to(true)
    end
  end
end
```

Note: `describe` blocks need `type: :controller` routing — add `controller(Admin::Chapters::OrganisersController) { }` style or split into two files mirroring repo conventions (`spec/controllers/admin/` has per-controller specs; follow `spec/controllers/admin/bans_controller_spec.rb` for the ban params shape). Check the existing specs and reuse their param shapes.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/activity_admin_actions_spec.rb`
Expected: FAIL on activity assertions.

- [ ] **Step 3: Instrument the three actions**

In `app/controllers/admin/chapters/organisers_controller.rb#create`, after `member.add_role(:organiser, @chapter)`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'organiser_role.granted',
                                  recipient: member, trackable: @chapter)
```

In `#destroy`, after `member.remove_role(:organiser, @chapter)`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'organiser_role.revoked',
                                  recipient: member, trackable: @chapter)
```

In `app/controllers/admin/bans_controller.rb#create`, inside `if @ban.save` before the mailer:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'member.banned',
                                    recipient: @ban.member, trackable: @ban)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/controllers/admin/activity_admin_actions_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/admin/chapters/organisers_controller.rb app/controllers/admin/bans_controller.rb spec/controllers/admin/activity_admin_actions_spec.rb
git commit -m 'Record organiser role changes and bans'
```

### Task 9: Admin invitation overrides and event verification

**Files:**
- Modify: `app/controllers/admin/invitations_controller.rb` (`update_to_attended`, `update_to_attending`, `update_to_not_attending`)
- Modify: `app/controllers/admin/invitation_controller.rb` (`update`, `verify`)
- Test: extend `spec/controllers/admin/invitations_controller_spec.rb`

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing tests**

Append to `spec/controllers/admin/invitations_controller_spec.rb` (follow the existing describe/setup scaffolding in that file — reuse its workshop/invitation/admin fixtures and `login` usage):

```ruby
  context 'activity recording' do
    it 'records invitation.rsvp_override when admin forces attendance' do
      # arrange: admin logged in, decorated workshop + invitation as in existing specs
      patch :update, params: { workshop_id: workshop.id, invitation: { id: invitation.token },
                               attending: 'true' }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.rsvp_override',
                                              recipient: invitation.member)).to be(true)
    end
  end
```

Add to the `Admin::InvitationController` spec (create `spec/controllers/admin/invitation_controller_spec.rb` if none exists):

```ruby
  it 'records invitation.verified on verify' do
    invitation = Fabricate(:event_invitation)
    admin = Fabricate(:member)
    admin.add_role(:admin)
    LoginHelpers::LoginStub.current_user = admin

    post :verify, params: { invitation_id: invitation.token }

    expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.verified',
                                            recipient: invitation.member)).to be(true)
  end
```

Note: these specs need the exact existing fixture idioms from the two files (`set_and_decorate_workshop` runs as before_action). Read both spec files first and mirror their setup; substitute variable names accordingly.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/invitations_controller_spec.rb spec/controllers/admin/invitation_controller_spec.rb`
Expected: FAIL on activity assertions.

- [ ] **Step 3: Instrument**

In `app/controllers/admin/invitations_controller.rb`, add one line at the top of each of `update_to_attended`, `update_to_attending`, and `update_to_not_attending` (after the method body's update completes — safest is immediately after its `@invitation.update(...)` line in each method):

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.rsvp_override',
                                  trackable: @invitation, recipient: @invitation.member)
```

In `app/controllers/admin/invitation_controller.rb`, in `update` after `invitation.update(attending: true, ...)`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.verified',
                                  trackable: invitation, recipient: invitation.member)
```

and identically in `verify` after its `invitation.update(...)`.

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/controllers/admin/invitations_controller_spec.rb spec/controllers/admin/invitation_controller_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/admin/invitations_controller.rb app/controllers/admin/invitation_controller.rb spec/controllers/admin/
git commit -m 'Record admin RSVP overrides and event verification'
```

### Task 10: Member notes and check-ins

**Files:**
- Modify: `app/controllers/admin/member_notes_controller.rb:5` (`create`)
- Modify: `app/controllers/check_ins_controller.rb:111` (`mark_attended`)
- Test: extend `spec/controllers/admin/member_notes_controller_spec.rb`; create `spec/requests/member_activity_check_in_spec.rb`

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing tests**

Append to `spec/controllers/admin/member_notes_controller_spec.rb` (mirror its existing setup):

```ruby
  it 'records member_note.created' do
    member = Fabricate(:member)
    LoginHelpers::LoginStub.current_user = admin # reuse the file's admin fixture name

    post :create, params: { member_note: { member_id: member.id, note: 'context' } }

    expect(PublicActivity::Activity.exists?(key: 'member_note.created', recipient: member)).to be(true)
  end
```

Create `spec/requests/member_activity_check_in_spec.rb`:

```ruby
# spec/requests/member_activity_check_in_spec.rb
require 'rails_helper'

RSpec.describe 'Check-in activity' do
  let(:invitation) { Fabricate(:workshop_invitation) }
  let(:member) { invitation.member }
  let(:workshop) { invitation.workshop }

  before do
    LoginHelpers::LoginStub.current_user = member
    workshop.update!(date_and_time: 1.hour.ago, check_in_code: '1234')
    allow_any_instance_of(Workshop).to receive(:check_in_open?).and_return(true)
  end

  after { LoginHelpers::LoginStub.current_user = nil }

  it 'records member.checked_in' do
    post check_ins_path, params: { check_in: { workshop_id: workshop.id, code: '1234', role: 'Student' } }

    expect(PublicActivity::Activity.exists?(owner: member, key: 'member.checked_in')).to be(true)
  end
end
```

Note: read `app/controllers/check_ins_controller.rb` first for the exact param contract (`load_check_in_target` consumes the params) and mirror an existing check-in spec if one exists (`rg -l "check_ins_path" spec/`).

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/member_notes_controller_spec.rb spec/requests/member_activity_check_in_spec.rb`
Expected: FAIL on activity assertions.

- [ ] **Step 3: Instrument**

In `app/controllers/admin/member_notes_controller.rb#create`, after `@note.author = current_user`:

```ruby
    if @note.save
      MemberActivityRecorder.record(actor: current_user, key: 'member_note.created',
                                    trackable: @note, recipient: @note.member)
    else
      flash[:error] = @note.errors.full_messages
    end
    redirect_back fallback_location: root_path
```

(replacing the existing `flash[:error] = @note.errors.full_messages unless @note.save` line).

In `app/controllers/check_ins_controller.rb#mark_attended`, at the end of the method after `invitation.update!(attrs)`:

```ruby
    MemberActivityRecorder.record(actor: invitation.member, key: 'member.checked_in',
                                  trackable: invitation)
```

Note: `mark_attended` is called both by self-service check-in and by admin flows; recording the invitation member (not `current_user`) is correct in both paths per the spec.

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/controllers/admin/member_notes_controller_spec.rb spec/requests/member_activity_check_in_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/admin/member_notes_controller.rb app/controllers/check_ins_controller.rb spec/controllers/admin/member_notes_controller_spec.rb spec/requests/member_activity_check_in_spec.rb
git commit -m 'Record member notes and check-in activity'
```

### Task 11: Workshop creation + `created_by_id`

**Files:**
- Create: `db/migrate/XXXXXXXX_add_created_by_id_to_workshops.rb`
- Modify: `app/models/workshop.rb` (`belongs_to :created_by, optional: true, class_name: 'Member'`)
- Modify: `app/controllers/admin/workshops_controller.rb:27` (`create`)
- Test: extend `spec/controllers/admin/workshops_controller_spec.rb`

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).
- Produces: `Workshop#created_by` → `Member` (nullable; NULL = unknown/pre-migration).

- [ ] **Step 1: Write the failing test**

Append to `spec/controllers/admin/workshops_controller_spec.rb` (mirror its existing `create` setup):

```ruby
  it 'stamps created_by and records workshop.created' do
    # arrange as in the file's existing create example

    expect(Workshop.last.created_by).to eq(admin) # reuse the file's admin fixture name
    expect(PublicActivity::Activity.exists?(owner: admin, key: 'workshop.created',
                                            trackable: Workshop.last)).to be(true)
  end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb`
Expected: FAIL — `created_by` undefined / no activity.

- [ ] **Step 3: Migration, association, instrumentation**

```bash
bin/rails generate migration AddCreatedByIdToWorkshops created_by_id:integer
```

Edit the generated migration to match the repo's foreign-key conventions:

```ruby
class AddCreatedByIdToWorkshops < ActiveRecord::Migration[8.1]
  def change
    add_column :workshops, :created_by_id, :integer
    add_index :workshops, :created_by_id
    add_foreign_key :workshops, :members, column: :created_by_id, on_delete: :nullify
  end
end
```

Run `bin/rails db:migrate`. In `app/models/workshop.rb` add:

```ruby
  belongs_to :created_by, class_name: 'Member', optional: true, foreign_key: :created_by_id
```

In `app/controllers/admin/workshops_controller.rb#create`, inside `if workshop_type_valid? && @workshop.save` before the redirect:

```ruby
      @workshop.update_column(:created_by_id, current_user.id)
      MemberActivityRecorder.record(actor: current_user, key: 'workshop.created',
                                    trackable: @workshop)
```

(`update_column` matches the stashed design's plumbing decision: a stamp, not a user-facing attribute.)

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add db/migrate/ app/models/workshop.rb app/controllers/admin/workshops_controller.rb spec/controllers/admin/workshops_controller_spec.rb db/schema.rb
git commit -m 'Stamp workshop creator and record workshop.created'
```

### Task 12: Admin subscription changes and meeting invitations

**Files:**
- Modify: `app/controllers/admin/members_controller.rb:40` (`update_subscriptions`)
- Modify: `app/controllers/admin/meeting_invitations_controller.rb` (`create`, `update`)
- Test: create `spec/requests/admin_activity_member_admin_spec.rb`

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing request spec**

```ruby
# spec/requests/admin_activity_member_admin_spec.rb
require 'rails_helper'

RSpec.describe 'Admin member management activity' do
  let(:admin) { Fabricate(:member) }
  let(:member) { Fabricate(:member) }
  let(:group) { Fabricate(:group) }

  before do
    admin.add_role(:admin)
    LoginHelpers::LoginStub.current_user = admin
  end

  after { LoginHelpers::LoginStub.current_user = nil }

  it 'records subscription.admin_updated' do
    member.subscriptions.create!(group: group)

    patch admin_member_update_subscriptions_path(member), params: { group: group.id }

    expect(PublicActivity::Activity.exists?(owner: admin, key: 'subscription.admin_updated',
                                            recipient: member)).to be(true)
  end

  it 'records meeting_invitation.created on admin invite' do
    meeting = Fabricate(:meeting)

    post admin_meeting_meeting_invitations_path(meeting),
         params: { meeting_invitations: { member: member.id, meeting_id: meeting.id } }

    expect(PublicActivity::Activity.exists?(owner: admin, key: 'meeting_invitation.created',
                                            recipient: member)).to be(true)
  end

  it 'records meeting_invitation.updated on admin update' do
    meeting = Fabricate(:meeting)
    invitation = Fabricate(:meeting_invitation, member: member, meeting: meeting)

    patch admin_meeting_meeting_invitation_path(meeting, invitation),
          params: { meeting_invitation: { attending: 'false' } }

    expect(PublicActivity::Activity.exists?(owner: admin, key: 'meeting_invitation.updated',
                                            recipient: member)).to be(true)
  end
end
```

Note: read `app/controllers/admin/members_controller.rb` for the real route names (`update_subscriptions` route member scope), `app/controllers/admin/meeting_invitations_controller.rb#update` for its actual params contract, and the meeting/meeting_invitation fabricator names; substitute before running.

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/requests/admin_activity_member_admin_spec.rb`
Expected: FAIL on activity assertions after fixing routes/fabricators.

- [ ] **Step 3: Instrument**

In `app/controllers/admin/members_controller.rb#update_subscriptions`, after `subscription.destroy`:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'subscription.admin_updated',
                                  trackable: group, recipient: @member)
```

In `app/controllers/admin/meeting_invitations_controller.rb#create`, inside `if invitation.save` after the mailer line:

```ruby
      MemberActivityRecorder.record(actor: current_user, key: 'meeting_invitation.created',
                                    trackable: invitation, recipient: member)
```

In `#update` (read the method first), immediately after its `invitation.update(...)` success path:

```ruby
    MemberActivityRecorder.record(actor: current_user, key: 'meeting_invitation.updated',
                                  trackable: invitation, recipient: invitation.member)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/requests/admin_activity_member_admin_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/admin/members_controller.rb app/controllers/admin/meeting_invitations_controller.rb spec/requests/admin_activity_member_admin_spec.rb
git commit -m 'Record admin subscription changes and meeting invitations'
```

### Task 13: InvitationLogger batch sends

**Files:**
- Modify: `app/services/invitation_logger.rb` (`start_batch`)
- Test: extend `spec/services/invitation_logger_spec.rb`

**Interfaces:**
- Consumes: `MemberActivityRecorder.record` (Task 1).

- [ ] **Step 1: Write the failing test**

Append to `spec/services/invitation_logger_spec.rb` (mirror its existing fabricator usage):

```ruby
  it 'records invitation.send_batch for the initiator' do
    initiator = Fabricate(:member)

    described_class.new(workshop, initiator, 'all', 'invite').start_batch

    expect(PublicActivity::Activity.exists?(owner: initiator, key: 'invitation.send_batch',
                                            trackable: workshop)).to be(true)
  end
```

(substitute the file's actual loggable fixture — workshop or event — and arguments).

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/services/invitation_logger_spec.rb`
Expected: FAIL.

- [ ] **Step 3: Instrument**

In `app/services/invitation_logger.rb#start_batch`, after the `@log = InvitationLog.create!(...)` block:

```ruby
    MemberActivityRecorder.record(actor: @initiator, key: 'invitation.send_batch', trackable: @loggable)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/services/invitation_logger_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/invitation_logger.rb spec/services/invitation_logger_spec.rb
git commit -m 'Record invitation batch sends as initiator activity'
```

### Task 14: PR 1 wrap-up

- [ ] **Step 1: Full suite + lint**

Run: `bundle exec parallel_rspec spec/ -n 3 && bundle exec rubocop app spec`
Expected: green.

- [ ] **Step 2: Push and open draft PR**

```bash
git push -u origin <branch>
gh pr create --draft --title 'Record member activity in the activities log' --body-file /tmp/pr1-body.md
```

PR body (write to `/tmp/pr1-body.md` first, no backticks in CLI args): summary = one funnel, closed key list, all write sites from the spec's Instrumentation section; test evidence = new specs listed; link the spec path.

---

# PR 2 — Visualisation

### Task 15: ActivityStrip service

**Files:**
- Create: `app/services/admin/members/activity_strip.rb`
- Test: `spec/services/admin/members/activity_strip_spec.rb` (create dirs)

**Interfaces:**
- Consumes: `PublicActivity::Activity` rows with `owner` = member (PR 1).
- Produces: `Admin::Members::ActivityStrip.new(member, now: Time.zone.now).rows` → array of 52 `Row` structs (`week_start: Date/Time`, `state: :empty|:login_only|:active`, `counts: Hash{String=>Integer}`), oldest week first, ending at the current ISO week.

- [ ] **Step 1: Write the failing tests**

```ruby
# spec/services/admin/members/activity_strip_spec.rb
require 'rails_helper'

RSpec.describe Admin::Members::ActivityStrip do
  let(:member) { Fabricate(:member) }
  let(:now) { Time.zone.local(2026, 9, 2, 12, 0, 0) } # Wednesday, current week starts Mon 31 Aug
  let(:strip) { described_class.new(member, now: now) }

  def activity_at(time, key: 'member.login')
    PublicActivity::Activity.create!(owner: member, key: key, created_at: time, updated_at: time)
  end

  it 'returns 52 rows oldest first' do
    rows = strip.rows

    expect(rows.size).to eq(52)
    expect(rows.first.week_start).to eq(Time.zone.local(2026, 8, 31))
    expect(rows.last.week_start).to eq(Time.zone.local(2026, 8, 31) + 51.weeks)
  end

  it 'marks weeks with no rows as empty' do
    expect(strip.rows.map(&:state)).to all(eq(:empty))
  end

  it 'marks login-only weeks as login_only' do
    activity_at(now - 2.weeks, key: 'member.login')

    expect(strip.rows[-3].state).to eq(:login_only)
  end

  it 'marks weeks with any non-login key as active' do
    activity_at(now - 2.weeks, key: 'event_invitation.rsvp')

    expect(strip.rows[-3].state).to eq(:active)
  end

  it 'counts keys for tooltips' do
    activity_at(now - 1.week, key: 'member.login')
    activity_at(now - 1.week, key: 'event_invitation.rsvp')

    expect(strip.rows[-2].counts).to eq('member.login' => 1, 'event_invitation.rsvp' => 1)
  end

  it 'buckets by ISO week with the boundary at window start' do
    activity_at(strip.rows.first.week_start) # exactly at the window edge
    activity_at(strip.rows.first.week_start - 1.second) # one second before: outside

    expect(strip.rows.first.state).to eq(:login_only)
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/services/admin/members/activity_strip_spec.rb`
Expected: FAIL — constant undefined.

- [ ] **Step 3: Write the service**

```ruby
# app/services/admin/members/activity_strip.rb
# frozen_string_literal: true

module Admin
  module Members
    # Buckets a member's activity log into the 52 ISO weeks ending the current week.
    # Sole owner of strip state classification; the component renders, never classifies.
    class ActivityStrip
      WEEK_COUNT = 52
      LOGIN_ONLY_KEYS = %w[member.login member.logout].freeze

      Row = Struct.new(:week_start, :state, :counts, keyword_init: true)

      def initialize(member, now: Time.zone.now)
        @member = member
        @now = now
      end

      def rows
        activities = PublicActivity::Activity
                     .where(owner: @member)
                     .where(created_at: window_start..@now)
                     .order(:created_at)

        grouped = activities.group_by { |a| a.created_at.to_date.beginning_of_week.beginning_of_day }

        weeks.map do |week_start|
          week_activities = grouped[week_start] || []
          counts = week_activities.map(&:key).tally
          state = classify(counts)

          Row.new(week_start: week_start, state: state, counts: counts)
        end
      end

      private

      def classify(counts)
        return :empty if counts.empty?
        return :login_only if counts.keys.all? { |key| LOGIN_ONLY_KEYS.include?(key) }

        :active
      end

      def weeks
        @weeks ||= Array.new(WEEK_COUNT) { |i| current_week_start - (WEEK_COUNT - 1 - i).weeks }
      end

      def window_start
        @window_start ||= current_week_start - (WEEK_COUNT - 1).weeks
      end

      def current_week_start
        @current_week_start ||= @now.to_date.beginning_of_week.beginning_of_day
      end
    end
  end
end
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/services/admin/members/activity_strip_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/admin/members/activity_strip.rb spec/services/admin/members/activity_strip_spec.rb
git commit -m 'Add admin member activity strip service'
```

### Task 16: ActivityStripComponent

**Files:**
- Create: `app/components/admin/members/activity_strip_component.rb`
- Create: `app/components/admin/members/activity_strip_component.html.erb`
- Create: `app/assets/stylesheets/partials/_activity_strip.scss`
- Modify: `app/assets/stylesheets/application.scss` (add `@import "partials/activity_strip";` next to the other partial imports)
- Test: `spec/components/admin/members/activity_strip_component_spec.rb`

**Interfaces:**
- Consumes: `Admin::Members::ActivityStrip#rows` (Task 15) — `Row(week_start:, state:, counts:)`.
- Produces: `Admin::Members::ActivityStripComponent.new(weeks: rows)`.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/components/admin/members/activity_strip_component_spec.rb
require 'rails_helper'

RSpec.describe Admin::Members::ActivityStripComponent, type: :component do
  let(:member) { Fabricate(:member) }
  let(:now) { Time.zone.local(2026, 9, 2, 12, 0, 0) }
  let(:rows) do
    Admin::Members::ActivityStrip.new(member, now: now).tap do |strip|
      PublicActivity::Activity.create!(owner: member, key: 'member.login',
                                       created_at: now - 1.week, updated_at: now - 1.week)
      PublicActivity::Activity.create!(owner: member, key: 'event_invitation.rsvp',
                                       created_at: now - 2.weeks, updated_at: now - 2.weeks)
    end.rows
  end

  before { render_inline(described_class.new(weeks: rows)) }

  it 'renders 52 cells' do
    expect(page).to have_css('rect', count: 52)
  end

  it 'renders all three state classes' do
    expect(page).to have_css('.activity-cell-empty')
    expect(page).to have_css('.activity-cell-login_only')
    expect(page).to have_css('.activity-cell-active')
  end

  it 'renders a tooltip with the week and counts' do
    expect(page).to have_css('rect[title*="event_invitation rsvp"]')
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/components/admin/members/activity_strip_component_spec.rb`
Expected: FAIL — constant undefined.

- [ ] **Step 3: Write the component**

```ruby
# app/components/admin/members/activity_strip_component.rb
# frozen_string_literal: true

module Admin
  module Members
    class ActivityStripComponent < ViewComponent::Base
      CELL_WIDTH = 8
      CELL_GAP = 4

      def initialize(weeks:)
        @weeks = weeks
      end

      private

      attr_reader :weeks

      def title_for(week)
        summary = week.counts.map { |key, count| "#{count} #{key.tr('.', ' ')}" }.join(', ')
        "Week of #{week.week_start.strftime('%-d %b %Y')}: #{summary.presence || 'no activity'}"
      end

      def svg_width
        weeks.size * (CELL_WIDTH + CELL_GAP)
      end
    end
  end
end
```

```erb
<%# app/components/admin/members/activity_strip_component.html.erb %>
<div class="activity-strip">
  <h5>Activity — last 12 months</h5>
  <svg viewBox="0 0 <%= svg_width %> 32" width="100%" height="32"
       role="img" aria-label="Weekly activity, last 12 months">
    <% weeks.each_with_index do |week, i| %>
      <rect x="<%= i * (CELL_WIDTH + CELL_GAP) %>" y="0"
            width="<%= CELL_WIDTH %>" height="32" rx="2"
            class="activity-cell activity-cell-<%= week.state %>"
            title="<%= title_for(week) %>" />
    <% end %>
  </svg>
</div>
```

```scss
// app/assets/stylesheets/partials/_activity_strip.scss
.activity-strip {
  .activity-cell {
    &-empty { fill: $gray-200; }
    &-login_only { fill: $gray-400; }
    &-active { fill: $codebar-purple; } // substitute the repo's brand colour variable
  }
}
```

Note: check `app/assets/stylesheets/partials/_colors.sass` for the real brand/ink variable names and use them; if none exist, use literal hex values matching the site's accent colour.

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/components/admin/members/activity_strip_component_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/components/admin/members/ app/assets/stylesheets/partials/_activity_strip.scss app/assets/stylesheets/application.scss spec/components/admin/members/activity_strip_component_spec.rb
git commit -m 'Add activity strip view component'
```

### Task 17: Profile integration

**Files:**
- Modify: `app/controllers/admin/members_controller.rb:26` (`show`)
- Modify: `app/views/admin/members/_profile.html.haml`
- Test: extend `spec/controllers/admin/members_controller_spec.rb`

**Interfaces:**
- Consumes: Tasks 15–16. `MemberPresenter` is a `SimpleDelegator`, so `@member.organiser?` resolves to the underlying member's method.

- [ ] **Step 1: Write the failing tests**

In `spec/controllers/admin/members_controller_spec.rb`, add (inside the existing `show` describe, mirroring its admin-login setup):

```ruby
    describe 'activity strip' do
      render_views

      let(:organiser) { Fabricate(:member) }
      let(:chapter) { Fabricate(:chapter) }

      before { organiser.add_role(:organiser, chapter) }

  it 'renders the strip for organisers' do
    get :show, params: { id: organiser.id }

    expect(response.body).to include('activity-strip')
  end

      it 'does not render the strip for non-organisers' do
        plain = Fabricate(:member)

        get :show, params: { id: plain.id }

        expect(response.body).not_to include('activity-strip')
      end
    end
```

- [ ] **Step 2: Run to verify failure**

Run: `bundle exec rspec spec/controllers/admin/members_controller_spec.rb`
Expected: FAIL — `activity_weeks` unassigned, strip absent.

- [ ] **Step 3: Controller and view**

In `app/controllers/admin/members_controller.rb`, replace `show` with (fetch the undecorated member first so both the presenter and the service use the same record):

```ruby
  def show
    member = Member.find(params[:id])
    @member = MemberPresenter.new(member)
    load_attendance_data(@member)
    @activity_weeks = Admin::Members::ActivityStrip.new(member).rows
    @actions = admin_actions(@member).sort_by(&:created_at).reverse
  end
```

In `app/views/admin/members/_profile.html.haml`, directly after the avatar/full-name block (top of the profile content):

```haml
  - if @member.organiser?
    = render Admin::Members::ActivityStripComponent.new(weeks: @activity_weeks)
```

- [ ] **Step 4: Run to verify pass**

Run: `bundle exec rspec spec/controllers/admin/members_controller_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/admin/members_controller.rb app/views/admin/members/_profile.html.haml spec/controllers/admin/members_controller_spec.rb
git commit -m 'Render organiser activity strip on admin member profile'
```

### Task 18: PR 2 wrap-up

- [ ] **Step 1: Full suite + lint**

Run: `bundle exec parallel_rspec spec/ -n 3 && bundle exec rubocop app spec`
Expected: green.

- [ ] **Step 2: Push and open draft PR**

```bash
git push -u origin <branch>
gh pr create --draft --title 'Organiser activity strip on admin member profile' --body-file /tmp/pr2-body.md
```

PR body (write to `/tmp/pr2-body.md` first): summary = service + component + profile placement behind organiser check; screenshots from local run (`bundle exec rails server`, visit `/admin/members/:id` as an admin, organiser with seeded activity); test evidence; link the spec path.
