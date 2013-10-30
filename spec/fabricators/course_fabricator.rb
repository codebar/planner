Fabricator(:course) do
  description { Faker::Lorem.paragraph }
  short_description { Faker::Lorem.sentence }
  title { Faker::Lorem.sentence }
  tutor { Fabricate(:coach) }
  date_and_time  { DateTime.now+1.week }

  seats 1
end
