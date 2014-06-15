Fabricator(:sessions) do
  date_and_time DateTime.now+2.days
  time DateTime.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor), host: true )
  end
end

Fabricator(:sessions_no_sponsor, class_name: :sessions) do
  name { Faker::Lorem.name }
  date_and_time DateTime.now+2.days
  time DateTime.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
end
