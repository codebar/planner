Fabricator(:announcement) do
  created_by(fabricator: :member)
  message { Faker::Lorem.sentence }
  expires_at { Time.zone.today + 1.month }
end
