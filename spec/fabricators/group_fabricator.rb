Fabricator(:group) do
  name "Students"
  description { Faker::Lorem.paragraph }
  chapter
end

Fabricator(:students, from: :group) do
  name "Students"
end

Fabricator(:coaches, from: :group) do
  name "Coaches"
end
