Fabricator(:course) do
  title { Faker::Lorem.sentence }
  short_description { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
  tutor { Fabricate(:member) }
  date_and_time { Time.zone.now + 1.week }
  seats 1
  url { Faker::Internet.url }
  sponsor
  chapter
end
