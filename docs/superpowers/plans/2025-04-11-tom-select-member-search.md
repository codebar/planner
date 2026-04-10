# TomSelect Member Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Chosen.js with TomSelect for member lookup on `/admin/members`, using remote data loading for on-demand search.

**Architecture:** New JSON endpoint returns searched members. TomSelect fetches results dynamically via the `load` callback. Only affects `/admin/members` - other pages continue using Chosen.js.

**Tech Stack:** Rails 8.1, TomSelect 2.4.3, Sprockets, jQuery, HAML

---

## Files

| File | Action | Purpose |
|------|--------|---------|
| `config/routes.rb` | Modify | Add `get :search` to admin members |
| `app/controllers/admin/members_controller.rb` | Modify | Add `search` action, simplify `index` |
| `app/views/admin/members/index.html.haml` | Modify | Empty select, remove `@members` usage |
| `app/assets/javascripts/application.js` | Modify | Add TomSelect init, exclude from Chosen |
| `app/assets/stylesheets/application.scss` | Modify | Require TomSelect CSS |
| `vendor/assets/javascripts/tom-select.complete.min.js` | Create | TomSelect JS library |
| `vendor/assets/stylesheets/tom-select.bootstrap5.min.css` | Create | TomSelect Bootstrap 5 theme |
| `spec/controllers/admin/members_controller_spec.rb` | Create | Controller tests for search action |
| `spec/features/admin/tom_select_member_lookup_spec.rb` | Create | Feature test for TomSelect behavior |

---

## Task 1: Download TomSelect Assets

**Files:**
- Create: `vendor/assets/javascripts/tom-select.complete.min.js`
- Create: `vendor/assets/stylesheets/tom-select.bootstrap5.min.css`

- [ ] **Step 1: Download TomSelect JavaScript**

```bash
curl -o vendor/assets/javascripts/tom-select.complete.min.js \
  https://cdn.jsdelivr.net/npm/tom-select@2.4.3/dist/js/tom-select.complete.min.js
```

- [ ] **Step 2: Download TomSelect Bootstrap 5 CSS**

```bash
curl -o vendor/assets/stylesheets/tom-select.bootstrap5.min.css \
  https://cdn.jsdelivr.net/npm/tom-select@2.4.3/dist/css/tom-select.bootstrap5.min.css
```

- [ ] **Step 3: Verify downloads**

```bash
ls -la vendor/assets/javascripts/tom-select.complete.min.js
ls -la vendor/assets/stylesheets/tom-select.bootstrap5.min.css
```

Expected: Both files exist with non-zero size.

- [ ] **Step 4: Commit**

```bash
git add vendor/assets/javascripts/tom-select.complete.min.js \
        vendor/assets/stylesheets/tom-select.bootstrap5.min.css
git commit -m "feat: add TomSelect 2.4.3 assets"
```

---

## Task 2: Add Search Route

**Files:**
- Modify: `config/routes.rb`

- [ ] **Step 1: Add search route to admin members**

In `config/routes.rb`, find the `namespace :admin` block and the `resources :members` line. Add `search` as a collection route:

```ruby
# config/routes.rb (within namespace :admin)
resources :members, only: %i[show index] do
  get :search, on: :collection
  get :events
  # ... rest of existing routes
end
```

The route should create `GET /admin/members/search(.:format)`.

- [ ] **Step 2: Verify route**

```bash
bundle exec rails routes | grep "admin/members/search"
```

Expected: `search_admin_members GET /admin/members/search(.:format) admin/members#search`

- [ ] **Step 3: Commit**

```bash
git add config/routes.rb
git commit -m "feat: add search route for admin members"
```

---

## Task 3: Write Controller Tests

**Files:**
- Create: `spec/controllers/admin/members_controller_spec.rb`

- [ ] **Step 1: Create controller spec file**

```ruby
# spec/controllers/admin/members_controller_spec.rb
require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  describe 'GET #search' do
    let(:admin) { Fabricate(:member) }
    let!(:member_jane) { Fabricate(:member, name: 'Jane', surname: 'Doe', email: 'jane@example.com') }
    let!(:member_john) { Fabricate(:member, name: 'John', surname: 'Smith', email: 'john@test.com') }

    before do
      admin.add_role(:admin)
      login_as_admin(admin)
    end

    context 'with query less than 3 characters' do
      it 'returns empty array' do
        get :search, params: { q: 'ab' }, format: :json
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'with query 3 or more characters' do
      it 'returns matching members by name' do
        get :search, params: { q: 'Jan' }, format: :json
        
        expect(response).to have_http_status(:ok)
        results = JSON.parse(response.body)
        expect(results.length).to eq(1)
        expect(results.first['id']).to eq(member_jane.id)
        expect(results.first['full_name']).to eq('Jane Doe')
      end

      it 'returns matching members by email' do
        get :search, params: { q: 'john@tes' }, format: :json
        
        expect(response).to have_http_status(:ok)
        results = JSON.parse(response.body)
        expect(results.length).to eq(1)
        expect(results.first['id']).to eq(member_john.id)
      end

      it 'returns JSON with correct shape' do
        get :search, params: { q: 'Jan' }, format: :json
        
        results = JSON.parse(response.body)
        expect(results.first.keys).to contain_exactly('id', 'name', 'surname', 'email', 'full_name')
      end

      it 'limits results to 50' do
        51.times { |i| Fabricate(:member, name: "Test#{i}", surname: 'User', email: "test#{i}@example.com") }
        
        get :search, params: { q: 'Test' }, format: :json
        
        results = JSON.parse(response.body)
        expect(results.length).to be <= 50
      end
    end

    context 'when not authenticated' do
      before { login(Fabricate(:member)) }

      it 'redirects to login' do
        get :search, params: { q: 'test' }, format: :json
        
        expect(response).to have_http_status(:found)
      end
    end
  end
end
```

**Note:** Uses `login_as_admin(admin)` helper defined in `spec/support/helpers/login_helpers.rb`.

- [ ] **Step 2: Run tests to verify they fail**

```bash
bundle exec rspec spec/controllers/admin/members_controller_spec.rb
```

Expected: Tests fail with "The action 'search' could not be found for Admin::MembersController"

- [ ] **Step 3: Commit**

```bash
git add spec/controllers/admin/members_controller_spec.rb
git commit -m "test: add specs for admin members search action"
```

---

## Task 4: Implement Search Action

**Files:**
- Modify: `app/controllers/admin/members_controller.rb`

- [ ] **Step 1: Add search action to controller**

In `app/controllers/admin/members_controller.rb`, add the `search` action:

```ruby
# app/controllers/admin/members_controller.rb
class Admin::MembersController < Admin::ApplicationController
  def index
    # @members = Member.all removed - members loaded dynamically via search
  end

  def show
    @member = Member.find(params[:id])
  end

  def events
    @member = Member.find(params[:id])
  end

  def search
    query = params[:q].to_s.strip

    if query.length >= 3
      members = Member.where(
        "CONCAT(name, ' ', surname) ILIKE :q OR email ILIKE :q",
        q: "%#{query}%"
      ).select(:id, :name, :surname, :email).limit(50)
    else
      members = []
    end

    render json: members.as_json(
      only: [:id, :name, :surname, :email],
      methods: [:full_name]
    )
  end

  private

  def set_member
    @member = Member.find(params[:member_id])
  end
end
```

**Note:** Keep existing methods (show, events, etc.). Only add the `search` action and remove `@members = Member.all` from `index`.

- [ ] **Step 2: Run tests to verify they pass**

```bash
bundle exec rspec spec/controllers/admin/members_controller_spec.rb
```

Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add app/controllers/admin/members_controller.rb
git commit -m "feat: add search action for member lookup"
```

---

## Task 5: Update View

**Files:**
- Modify: `app/views/admin/members/index.html.haml`

- [ ] **Step 1: Update view to use empty select**

Replace the select_tag line. The full file should be:

```haml
.container.py-4.py-lg-5
  .row.mb-4
    .col
      %h1 Members Directory
  .row.mb-4
    .col-12.col-md-6
      = select_tag 'member_lookup_id', nil, class: 'form-control'
  .row
    .col
      = link_to 'View Profile', '#', class: 'btn btn-primary', id: 'view_profile'
```

Key changes:
- Removed `options_for_select([['Select a member...', '']] + @members.collect{ ... })` 
- Select is now empty - TomSelect populates it dynamically
- Removed `chosen-select` class - TomSelect will handle this element

- [ ] **Step 2: Commit**

```bash
git add app/views/admin/members/index.html.haml
git commit -m "feat: update member lookup to use empty select for TomSelect"
```

---

## Task 6: Add TomSelect CSS toManifest

**Files:**
- Modify: `app/assets/stylesheets/application.scss`

- [ ] **Step 1: Add TomSelect CSS require**

In `app/assets/stylesheets/application.scss`, add the require after `chosen` (around line 17):

```scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require font_awesome5
 *= require main
 *= require pickadate/classic
 *= require pickadate/classic.date
 *= require pickadate/classic.time
 *= require chosen
 *= require tom-select.bootstrap5.min
 */

@import "partials/colors";
@import "partials/layout";
@import "partials/hero";
@import "partials/social_media";
@import "partials/star-rating";

$primary: $dark-codebar-blue !default;

@import "bootstrap-custom";

/* Bootstrap's Reboot sets legends to float: left, which puts the first check box in a fieldset off to the
   right instead of underneath the legend. This overrides that. */
legend {
  float: none !important;
}
```

- [ ] **Step 2: Commit**

```bash
git add app/assets/stylesheets/application.scss
git commit -m "feat: add TomSelect CSS to asset manifest"
```

---

## Task 7: Add TomSelect JS to Manifest

**Files:**
- Modify: `app/assets/javascripts/application.js`

- [ ] **Step 1: Add TomSelect require**

At the top of `app/assets/javascripts/application.js`, add the require for TomSelect after `chosen.jquery`:

```javascript
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require popper
//= require bootstrap
//= require rails-ujs
//= require activestorage
//= require chosen.jquery
//= require tom-select.complete.min
//= require 'jsimple-star-rating.min.js'
//= require pickadate/picker
//= require pickadate/picker.date
//= require pickadate/picker.time
//= require subscriptions-toggle
//= require invitations
//= require dietary-restrictions
//= require cocoon
//= require font_awesome5
//= require how-you-found-us
```

- [ ] **Step 2: Commit**

```bash
git add app/assets/javascripts/application.js
git commit -m "feat: add TomSelect JS to asset manifest"
```

---

## Task 8: Initialize TomSelect

**Files:**
- Modify: `app/assets/javascripts/application.js` (same file as Task7)

- [ ] **Step 1: Add TomSelect initialization and exclude from Chosen**

Replace the Chosen initialization block (lines 43-67) with the updated version that:
1. Initializes TomSelect on `#member_lookup_id` first
2. Excludes `#member_lookup_id` from Chosen

The updated `$(function() { ... })` block should be:

```javascript
$(function() {
  $("body").removeClass("no-js");

  $('#event_local_date, #meeting_local_date, #workshop_local_date, #workshop_rsvp_open_local_date').pickadate({
    format: 'dd/mm/yyyy'
  });
  $('#announcement_expires_at, #ban_expires_at').pickadate();
  $(
    "#meeting_local_time, #meeting_local_end_time, #event_local_time, #event_local_end_time, #workshop_local_time, #workshop_local_end_time, #workshop_rsvp_open_local_time"
  ).pickatime({
    format: "HH:i",
  });

  // TomSelect for admin member lookup
  if ($('#member_lookup_id').length) {
    new TomSelect('#member_lookup_id', {
      placeholder: 'Type to search members...',
      valueField: 'id',
      labelField: 'full_name',
      searchField: ['full_name', 'email'],
      create: false,
      loadThrottle: 300,
      shouldLoad: function(query) {
        return query.length >= 3;
      },
      load: function(query, callback) {
        fetch('/admin/members/search?q=' + encodeURIComponent(query))
          .then(response => response.json())
          .then(json => callback(json))
          .catch(() => callback());
      },
      render: {
        option: function(item, escape) {
          return '<div>' + escape(item.full_name) + ' <small class="text-muted">' + escape(item.email) + '</small></div>';
        }
      }
    });

    $('#member_lookup_id').on('change', function() {
      $('#view_profile').attr('href', '/admin/members/' + $(this).val());
    });
  }

  // Chosen for all other selects (unchanged, but exclude #member_lookup_id)
  $('select').not('#member_lookup_id').on('chosen:ready', function () {
    var height = $(this).next('.chosen-container').height();
    var width = $(this).next('.chosen-container').width();

    $(this).css({
      position: 'absolute',
      height: height,
      width: width,
      opacity: 0
    }).show();
  });

  $('select').not('#member_lookup_id').chosen({
    allow_single_deselect: true,
    no_results_text: 'No results matched'
  });

  $('[data-bs-toggle="tooltip"]').tooltip();
});
```

- [ ] **Step 2: Commit**

```bash
git add app/assets/javascripts/application.js
git commit -m "feat: initialize TomSelect for member lookup, exclude from Chosen"
```

---

## Task 9: Feature Test for TomSelect

**Files:**
- Create: `spec/features/admin/tom_select_member_lookup_spec.rb`

**Note:** Named `tom_select_member_lookup_spec.rb` to avoid collision with existing `member_search_spec.rb`.

- [ ] **Step 1: Create feature spec**

```ruby
# spec/features/admin/tom_select_member_lookup_spec.rb
require 'rails_helper'

RSpec.describe 'Admin TomSelect Member Lookup', type: :feature, js: true do
  let(:admin) { Fabricate(:member) }
  let!(:member_jane) { Fabricate(:member, name: 'Jane', surname: 'Doe', email: 'jane@example.com') }
  let!(:member_john) { Fabricate(:member, name: 'John', surname: 'Smith', email: 'john@test.com') }

  before do
    admin.add_role(:admin)
    login_as_admin(admin)
  end

  scenario 'searching for members with TomSelect' do
    visit admin_members_path

    # TomSelect should be initialized
    expect(page).to have_css('.ts-wrapper')
    
    # Type less than 3 characters - no search triggered
    find('.ts-input').click
    find('.ts-input').send_keys('Ja')
    
    # Wait a bit for potential (but shouldn't happen) search
    sleep 0.5
    
    # Type 3+ characters to trigger search
    find('.ts-input').send_keys('ne')
    
    # Wait for results to load
    expect(page).to have_css('.ts-dropdown .option', wait: 5)
    
    # Should show Jane Doe
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content('jane@example.com')
    
    # Should not show John
    expect(page).not_to have_content('John Smith')
  end

  scenario 'selecting a member updates view profile link' do
    visit admin_members_path

    find('.ts-input').click
    find('.ts-input').send_keys('Jane Doe')
    
    # Wait for results
    expect(page).to have_css('.ts-dropdown .option', wait: 5)
    
    # Click the option
    find('.ts-dropdown .option', text: 'Jane Doe').click
    
    # View Profile link should update
    expect(find('#view_profile')[:href]).to eq(admin_member_path(member_jane))
  end
end
```

**Note:** Uses `login_as_admin(admin)` helper from `spec/support/helpers/login_helpers.rb`. The helper mocks `current_user` on ApplicationController, which works with Playwright JS tests.

- [ ] **Step 2: Run feature test to verify behavior**

```bash
bundle exec rspec spec/features/admin/tom_select_member_lookup_spec.rb
```

Expected: Tests pass (may need debugging for browser timing).

- [ ] **Step 3: Commit**

```bash
git add spec/features/admin/tom_select_member_lookup_spec.rb
git commit -m "test: add feature test for TomSelect member lookup"
```

---

## Task 10: Integration Test

**Files:**
- None (manual testing)

- [ ] **Step 1: Start the server**

```bash
bundle exec rails server
```

- [ ] **Step 2: Test the member search manually**

1. Navigate to `/admin/members`
2. Verify the select field appears with placeholder "Type to search members..."
3. Type 2 characters - verify no search happens
4. Type 3+ characters - verify search triggers and shows results
5. Click a result - verify "View Profile" link updates
6. Click "View Profile" - verify it navigates to the member page

- [ ] **Step 3: Verify Chosen still works elsewhere**

1. Navigate to `/admin/workshops` or another page using Chosen
2. Verify Chosen dropdowns still work correctly

---

## Task 11: Final Commit

- [ ] **Step 1: Run all tests**

```bash
bundle exec rspec
```

- [ ] **Step 2: Run linter**

```bash
bundle exec rubocop
```

Expected: No offenses.

- [ ] **Step 3: Final review of changes**

```bash
git status
git log --oneline -10
```

- [ ] **Step 4: Create feature branch summary (if needed)**

If working on a feature branch, ensure all commits are squashed or organized appropriately before merge.