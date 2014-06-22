Fabricate.sequence(:name) { |i| "#{Faker::Lorem.word}#{i}" }

Fabricator(:chapter) do
  name { Fabricate.sequence(:name) }
  city { Faker::Lorem.word }
  email { Faker::Internet.email }
end
