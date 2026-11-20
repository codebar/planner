# Parameter handling

Loaded on demand from `AGENTS.md` (Parameter Handling section).

This application uses Rails 8.0 `params.expect` for parameter filtering and validation.

## Basic Pattern

Use `params.expect` instead of `params.require().permit()`:

```ruby
def resource_params
  params.expect(resource: [
    :field1, :field2, :field3
  ])
end
```

## Type Safety

Controllers using `params.expect` raise `ActionController::ParameterMissing` when:
- Parameter type is tampered (e.g., string sent instead of hash)
- Required parameters are missing
- Nested parameter structure is invalid

This makes parameter validation failures explicit and easier to handle at the application level.

## Nested Arrays

Use hash syntax for array parameters:

```ruby
params.expect(workshop: [
  :name, :date,
  { sponsor_ids: [] }
])
```

## Nested Attributes

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

## Conditional Parameters

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

## Return Value

`params.expect(key: [...])` returns the **inner permitted parameters**, not wrapped:

```ruby
result = params.expect(member: [:name, :email])
# Access as: result[:name], NOT result[:member][:name]
```

## Testing

Controller specs should verify parameter filtering works:

```ruby
it 'filters unpermitted parameters' do
  post :create, params: { resource: valid_attrs, hacker_field: 'malicious' }
  expect(response).to be_successful # hacker_field is filtered out
end
```
