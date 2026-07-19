Fabricator(:auth_service) do
  provider 'codebar'
  uid { Fabricate.sequence(:uid) { |n| "sq#{n}" } }
end
