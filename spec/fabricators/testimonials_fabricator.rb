Fabricator(:testimonial) do
  member
  text { Faker::Lorem.paragraph }
end
