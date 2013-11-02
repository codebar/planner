Fabricator(:sponsor) do
  name { Faker::Name.name }
  description { Faker::Lorem.paragraph }
  address { Fabricate(:address) }
end
