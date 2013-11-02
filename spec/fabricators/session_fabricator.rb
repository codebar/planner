Fabricator(:sessions) do
  seats 1
  date_and_time { DateTime.new }
end
