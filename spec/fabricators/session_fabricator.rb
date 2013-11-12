Fabricator(:sessions) do
  date_and_time { DateTime.now+2.days }
  title "Course title"
  after_build do |sessions|
    Fabricate(:sponsor_session, sessions: sessions, sponsor: Fabricate(:sponsor), host: true )
  end
end
