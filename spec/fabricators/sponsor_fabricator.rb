Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { Faker::Internet.domain_name }
  avatar { Faker::Internet.url }
  address { Fabricate(:address) }
end
