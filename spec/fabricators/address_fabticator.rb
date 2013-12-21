Fabricator(:address) do
  flat { Faker::Address.street_name }
  street { Faker::Address.street_address }
  postal_code { Faker::Address.postcode }
end
