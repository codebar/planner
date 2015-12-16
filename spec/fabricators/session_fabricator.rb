Fabricator(:sessions) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor), host: true )
  end
end

Fabricator(:sessions_no_sponsor, class_name: :sessions) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
end

Fabricator(:sessions_no_spots, class_name: :sessions) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor, seats: 0), host: true )
  end
end

Fabricator(:sessions_random_allocate, class_name: :sessions) do
  date_and_time DateTime.now+2.days
  time DateTime.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  random_allocate_at DateTime.now
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor), host: true )
  end
end
