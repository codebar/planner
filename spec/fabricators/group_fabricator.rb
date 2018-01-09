Fabricator(:group) do
  name 'Students'
  description { Faker::Lorem.paragraph }
  chapter
end

Fabricator(:students, from: :group) do
  name 'Students'
  members(count: 5)
end

Fabricator(:coaches, from: :group) do
  name 'Coaches'
  members(count: 5)
end
