Fabricator(:auth_service) do
  provider { Faker::Company.name }
  uid { Fabricate.sequence(:uid) }
end
