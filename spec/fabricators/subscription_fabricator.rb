Fabricator(:subscription) do
  member
  group
end

Fabricator(:discarded_subscription, from: :subscription) do
  discarded_at { Time.current }
end
