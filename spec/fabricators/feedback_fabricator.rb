Fabricator(:feedback) do
  request { Faker::Lorem.paragraph }
  suggestions { Faker::Lorem.paragraph }
end