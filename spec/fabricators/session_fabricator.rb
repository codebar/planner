Fabricator(:sessions) do
  date_and_time { DateTime.now+2.days }
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor), host: true )
  end
end
