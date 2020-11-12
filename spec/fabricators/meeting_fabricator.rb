Fabricator(:meeting) do
  name        { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
  date_and_time { Time.zone.now + 1.week }
  ends_at       { Time.zone.now + 1.week + 2.hours }
  # sponsor
  venue { Fabricate(:sponsor) }
  invitable true
  # invites_sent
  spaces 20
  # created_at
  # updated_at
end
