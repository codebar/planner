Fabricator(:member) do
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.paragraph }
  twitter { Faker::Name.first_name }
  auth_services(count: 1) { Fabricate(:auth_service) }
end

Fabricator(:student, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:students) }
end

Fabricator(:coach, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:coaches) }
end
