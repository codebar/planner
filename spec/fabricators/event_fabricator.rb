Fabricator(:event) do
  date_and_time DateTime.now+2.days
  ends_at DateTime.now+2.days+8.hours
  name Faker::Lorem.sentence
  description Faker::Lorem.sentence
  coach_description Faker::Lorem.sentence
  schedule Faker::Lorem.sentence
  venue { Fabricate(:sponsor) }
  coach_spaces 2
  student_spaces 2
  slug "some-slug"
  info Faker::Lorem.sentence
  after_build do |event|
    Fabricate(:sponsorship, event: event, sponsor: Fabricate(:sponsor))
  end
end
