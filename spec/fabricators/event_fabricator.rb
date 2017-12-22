Fabricator(:event) do
  date_and_time Time.zone.now + 2.days
  ends_at Time.zone.now + 2.days + 8.hours
  name Faker::Lorem.sentence
  description Faker::Lorem.sentence
  coach_description Faker::Lorem.sentence
  schedule Faker::Lorem.sentence
  venue { Fabricate(:sponsor) }
  coach_spaces 2
  invitable true
  coach_questionnaire { "http://#{Faker::Internet.domain_name}" }
  student_questionnaire { "http://#{Faker::Internet.domain_name}" }
  student_spaces 2
  slug 'some-slug'
  info Faker::Lorem.sentence
  begins_at '11:00'
  chapters { [Fabricate(:chapter)] }
  after_build do |event|
    Fabricate(:sponsorship, event: event, sponsor: Fabricate(:sponsor))
  end
end
