Fabricator(:feedback) do
  coach(fabricator: :coach)
  tutorial
  rating 5
  request { Faker::Lorem.paragraph }
  suggestions { Faker::Lorem.paragraph }
  workshop
end

Fabricator(:feedback_empty, class_name: :feedback)
