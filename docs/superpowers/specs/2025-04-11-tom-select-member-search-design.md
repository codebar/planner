# TomSelect Member Search Design

**Date:** 2025-04-11
**Status:** Draft
**Scope:** Replace Chosen.js with TomSelect on `/admin/members` for member lookup

## Problem

The member lookup dropdown on `/admin/members` currently uses Chosen.js and loads **all members** into the select dropdown on page load. As member count grows, this becomes:
- Slow to render
- Heavy on initial page load
- Difficult to find members in a large list

## Solution

Replace Chosen.js with TomSelect for the member lookup field, using remote data loading to search members on-demand instead of loading all members upfront.

### Key Constraints
- Chosen.js remains in use elsewhere (feedback forms, workshop invitations, etc.)
- Only `/admin/members` uses TomSelect for now
- Search must cover both name and email fields
- Minimum 3 characters before triggering search
- Debouncing via TomSelect's `loadThrottle` (300ms)

## Architecture

### Data Flow

```
User types (≥3 chars) → TomSelect queries /admin/members/search?q=term
                                          ↓
                              Rails controller searches name+email
                                          ↓
                              Returns JSON: [{id, name, surname, email, full_name}]
                                          ↓
                              TomSelect displays results in dropdown
                                          ↓
                              User selects → "View Profile" link updates
```

### Components

1. **Backend: `Admin::MembersController#search`**
   - New action responding with JSON
   - Searches `CONCAT(name, ' ', surname) ILIKE ? OR email ILIKE ?`
   - Returns max 50 results
   - Admin-only authentication (via `Admin::ApplicationController`)

2. **Frontend: TomSelect initialization**
   - Replaces Chosen.js for `#member_lookup_id` only
   - Uses native `fetch` for API calls
   - Custom renderer showing name + email inline

3. **Assets: TomSelect library**
   - Download JS: `https://cdn.jsdelivr.net/npm/tom-select@2.4.3/dist/js/tom-select.complete.min.js`
     - Save to `vendor/assets/javascripts/tom-select.complete.min.js`
   - Download CSS: `https://cdn.jsdelivr.net/npm/tom-select@2.4.3/dist/css/tom-select.bootstrap5.min.css`
     - Save to `vendor/assets/stylesheets/tom-select.bootstrap5.min.css`

## Implementation Details

### Route

```ruby
# config/routes.rb
namespace :admin do
  resources :members, only: %i[show index] do
    get :search, on: :collection
    # ... existing routes
  end
end
```

### Controller

```ruby
# app/controllers/admin/members_controller.rb
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
```

### View

```haml
# app/views/admin/members/index.html.haml
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

**Note:** Placeholder text is configured in TomSelect JS options, not as an HTML attribute on `<select>`.

### Controller Index Action

Remove `@members = Member.all` from the index action since members are now loaded dynamically via the search endpoint:

```ruby
# app/controllers/admin/members_controller.rb
def index
  # @members = Member.all  # REMOVED - no longer needed
end
```

### JavaScript

```javascript
// app/assets/javascripts/application.js

// Add: //= require tom-select.complete.min

$(function() {
  // ... existing pickadate code unchanged ...

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

  // Chosen for all other selects (unchanged)
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
});
```

### Stylesheet

```scss
// app/assets/stylesheets/application.scss
// Add after existing requires:
//*= require tom-select.bootstrap5.min
```

**Note:** The require must come after `*= require chosen` and before `@import` statements to match the existing manifest structure.

## Testing

### Controller Specs

New file: `spec/controllers/admin/members_controller_spec.rb` (or add to existing)

```ruby
describe 'GET #search' do
  it 'returns empty array for query < 3 characters'
  it 'returns matching members for query >= 3 characters'
  it 'searches both name and email fields'
  it 'returns JSON with correct shape'
  it 'limits results to 50'
end
```

### Feature Specs (Optional)

New file: `spec/features/admin/member_search_spec.rb`

Test TomSelect behavior:
- Type 2 characters, no search triggered
- Type 3+ characters, search triggered
- Results display correctly
- Selecting member updates "View Profile" link

## Rollout & Rollback

1. Deploy backend changes first (new route/controller)
2. Deploy frontend changes (TomSelect assets, JS)
3. Monitor for errors

**Rollback:**
- Revert view change (restore `options_for_select` with `@members`)
- Remove TomSelect JS initialization
- TomSelect CSS/JS files can remain (unused but harmless)

## Out of Scope

- Replacing Chosen.js on other pages (feedback forms, workshop invitations)
- Pagination for search results (50 result limit acceptable)
- Member search API for other consumers