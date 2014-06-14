Fabricator(:group) do
  name { Faker::Lorem.word }
  description { Faker::Lorem.paragraph }
  chapter
end

Fabricator(:students, class_name: :group) do
  name "Students"
  description { Faker::Lorem.paragraph }
  chapter
end
