Fabricator(:sessions) do
  seats 1
  date_and_time { DateTime.now+2.days }
  title "Course title"
end
