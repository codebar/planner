# Rails params.expect Migration Analysis

**Date:** 2026-02-09
**Project:** codebar planner
**Rails Version:** 7.2 → 8.0 upgrade path

## Executive Summary

Converting codebar planner to use Rails 8.0's `params.expect` requires migrating 20 controller files with 17 private parameter methods and eliminating 83 direct hash accesses. The migration is moderate effort (4-6 days) with significant security benefits, particularly for the payments controller.

## What is params.expect?

Rails 8.0 introduces `params.expect` to replace the `require().permit()` pattern. The new method handles type tampering securely by returning 400 errors instead of throwing exceptions when parameters are malformed.

### Syntax Comparison

```ruby
# Current (Rails 7.2)
params.require(:user).permit(:name, :handle, address: [:street, :city])

# New (Rails 8.0)
params.expect(user: [:name, :handle, { address: [:street, :city] }])
```

Key changes:
- Single method call replaces chained methods
- Nested parameters use hash syntax `{ key: [...] }` instead of `key: [...]`
- Type tampering returns 400 instead of raising `NoMethodError`

## Current State Analysis

### Strong Parameters Adoption

The codebase shows moderate adoption of strong parameters:

- **20 files** use `params.require().permit()`
- **17 private methods** follow consistent naming (`workshop_params`, `event_params`, etc.)
- **83 direct hash accesses** bypass parameter filtering (`params[:key]` pattern)
- **Good patterns:** Most admin controllers use private methods for parameter extraction
- **Security gaps:** Payment processing and member details use unpermitted access

### Most Complex Structures

**Sponsors (app/controllers/admin/sponsors_controller.rb:66-71)**
```ruby
params.require(:sponsor).permit(
  :name, :avatar, :website, :seats, :accessibility_info,
  :number_of_coaches, :level, :description,
  address_attributes: [:id, :flat, :street, :postal_code, :city, :latitude, :longitude, :directions],
  contacts_attributes: [:id, :name, :surname, :email, :mailing_list_consent, :_destroy]
)
```

**Events (app/controllers/admin/events_controller.rb:75-82)**
```ruby
params.require(:event).permit(
  :virtual, :name, :slug, :date_and_time, :local_date, :local_time, :local_end_time,
  :description, :info, :schedule, :venue_id, :external_url, :coach_spaces, :student_spaces,
  :email, :announce_only, :tito_url, :invitable, :time_zone, :student_questionnaire,
  :confirmation_required, :surveys_required, :audience, :coach_questionnaire, :show_faq,
  :display_coaches, :display_students,
  bronze_sponsor_ids: [], silver_sponsor_ids: [], gold_sponsor_ids: [], sponsor_ids: [],
  chapter_ids: []
)
```

## Migration Priorities

### High Priority (Security Critical)

**1. payments_controller.rb**
- **Risk:** Direct nested access to Stripe parameters
- **Current:** `params[:data][:email]`, `params[:data][:id]`, `params[:name]`
- **Impact:** Financial transaction security
- **Effort:** 4-6 hours with thorough testing

**2. member/details_controller.rb**
- **Risk:** Mixed permitted/unpermitted access with custom validation
- **Current:** Manual reassignment from raw params after permit
- **Complexity:** Conditional logic requires dynamic array building
- **Effort:** 6-8 hours

**3. admin/member_search_controller.rb**
- **Risk:** Multiple raw nested accesses
- **Current:** `params[:member_search]` and `params[:member_pick][:members]`
- **Effort:** 3-4 hours

### Medium Priority (Standard Controllers)

15-17 admin controllers with good strong parameters:
- workshops_controller.rb (5 fields + nested array)
- events_controller.rb (22+ fields with 4 nested arrays)
- sponsors_controller.rb (nested attributes with accepts_nested_attributes_for)
- meetings_controller.rb (9 fields + chapters array)
- chapters_controller.rb
- announcements_controller.rb
- groups_controller.rb

**Effort:** 1-2 hours each, 2-3 days total

### Low Priority (Simple Conversions)

Controllers with minimal or straightforward parameter handling:
- Direct one-to-one conversion possible
- No complex conditional logic
- Already using strong parameters consistently

**Effort:** 1-2 hours total

## Technical Challenges

### Conditional Parameter Handling

Some controllers use conditional logic:

```ruby
# Current pattern
params[:workshop_invitation].present? ?
  params.require(:workshop_invitation).permit(...) :
  {}
```

**Solution:** Build allowed keys dynamically:
```ruby
permitted_keys = [:name, :role]
permitted_keys << :admin if current_user.admin?
params.expect(user: permitted_keys)
```

### Nested Attributes

Controllers using `accepts_nested_attributes_for` need careful conversion:

```ruby
# Current
address_attributes: [:id, :flat, :street],
contacts_attributes: [:id, :name, :_destroy]

# New
{ address_attributes: [:id, :flat, :street] },
{ contacts_attributes: [:id, :name, :_destroy] }
```

### Data Transformation

Some controllers manipulate parameters after permit:

```ruby
params.require(:member).permit(...).tap do |params|
  params[:dietary_restrictions] = params[:dietary_restrictions].reject(&:blank?)
end
```

This pattern remains valid with `params.expect`.

## Testing Requirements

Each migration must verify:

1. **Type tampering:** Send string where hash expected, confirm 400 error
2. **Missing parameters:** Omit required keys, confirm 400 error
3. **Valid requests:** Confirm existing functionality unchanged
4. **Nested structures:** Test deep nesting and arrays
5. **Edge cases:** Empty arrays, nil values, boundary conditions

Use RSpec request specs with explicit parameter tampering tests.

## Migration Timeline

### Phase 1: Security Critical (1-2 days)
- Fix payments_controller.rb
- Fix member/details_controller.rb
- Fix admin/member_search_controller.rb
- Add type tampering tests
- Manual QA for payment flows

### Phase 2: Standard Controllers (2-3 days)
- Convert 15-17 admin controllers
- Update all private params methods
- Add request specs for parameter validation
- Handle nested arrays and attributes

### Phase 3: Cleanup (1 day)
- Eliminate 83 direct hash accesses
- Standardize conditional parameter patterns
- Add helper methods for complex cases
- Update concerns with parameter handling
- Documentation and final review

**Total Estimated Effort:** 4-6 days

## Implementation Strategy

### Approach

1. **One controller at a time:** Reduce merge conflicts
2. **Tests first:** Add type tampering specs before conversion
3. **Small PRs:** One controller category per pull request
4. **Gradual rollout:** Deploy and monitor between phases

### Pull Request Structure

- **PR 1:** Payments controller (security critical)
- **PR 2:** Member details controller
- **PR 3:** Member search and admin concerns
- **PR 4:** Workshop and event controllers
- **PR 5:** Sponsor and meeting controllers
- **PR 6:** Remaining admin controllers
- **PR 7:** Direct hash access cleanup

### Rollback Plan

If issues arise:
- Each PR is independently revertible
- No breaking changes to external APIs
- Existing behavior preserved (400 errors are improvement, not breaking change)
- Monitor error tracking (Rollbar) for unexpected parameter issues

## Benefits

### Security Improvements

- **Type tampering protection:** Malformed parameters return 400, not 500
- **Consistent validation:** Single method reduces bypass opportunities
- **Better error messages:** Rails provides clear parameter validation errors

### Code Quality

- **Cleaner syntax:** Single method call more readable
- **Explicit structure:** Nested parameters clearly visible in code
- **Standardization:** Eliminates 83 direct hash accesses

### Maintenance

- **Easier audits:** Parameter requirements in one place
- **Reduced confusion:** No mixing of permitted and unpermitted access
- **Better documentation:** Parameter structure self-documenting

## Risks

### Compatibility

- Requires Rails 8.0 (check upgrade timeline)
- May expose existing parameter handling bugs
- Tests expecting 500 errors need updates for 400 errors

### Complexity

- Conditional parameters need refactoring
- Nested attributes require careful syntax translation
- Data transformation patterns may need adjustment

### Testing

- Must test all parameter edge cases
- Payment flows require manual QA
- Integration tests may need updates

## Recommendations

1. **Start immediately after Rails 8.0 upgrade** (not before)
2. **Begin with payments_controller.rb** for maximum security benefit
3. **Create helper method** for conditional parameter building
4. **Add request specs** for type tampering across all controllers
5. **Deploy incrementally** with monitoring between phases
6. **Document patterns** for conditional and nested parameters

## Conclusion

Converting codebar planner to `params.expect` is moderate effort with significant security benefits. The 20 controller files using strong parameters follow consistent patterns that translate cleanly to the new syntax. The main challenges are the 4 high-priority controllers with unpermitted access and the 83 direct hash accesses requiring refactoring.

The payments controller alone justifies the migration effort due to security improvements in financial transaction handling. The remaining controllers benefit from cleaner syntax and better type safety.

Estimated timeline of 4-6 days is achievable with incremental pull requests and thorough testing. The migration should begin after the Rails 8.0 upgrade and deploy in phases with monitoring between each phase.
