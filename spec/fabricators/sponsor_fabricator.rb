Fabricator(:sponsor) do
  name { Faker::Name.name }
  description { Faker::Lorem.paragraph }
  avatar { Faker::Internet.url }
  address { Fabricate(:address) }
end
