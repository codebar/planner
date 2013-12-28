Fabricator(:feedback) do
  coach
  tutorial
  request { Faker::Lorem.paragraph }
  suggestions { Faker::Lorem.paragraph }
end

Fabricator(:feedback_empty, class_name: :feedback)