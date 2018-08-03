Fabricator(:tutorial) do
  title { Faker::Job.title }
  description { Faker::Lorem.paragraph }
  url { Faker::Internet.url }
end
