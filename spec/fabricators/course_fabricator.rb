Fabricator(:course) do
  description { Faker::Lorem.paragraph }
  short_description { Faker::Lorem.sentence }
  title { Faker::Lorem.sentence }
  tutor { Fabricate(:member) }
  chapter
  date_and_time { Time.zone.now + 1.week }
  sponsor

  seats 1
end
