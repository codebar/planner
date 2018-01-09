Fabricator(:meeting) do
  name        { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    date_and_time { Time.zone.now + 1.week }
    # sponsor
    venue { Fabricate(:sponsor) }
    invitable true
    # invites_sent
    slug 'some-slug'
    spaces 20
    # created_at
    # updated_at
end
