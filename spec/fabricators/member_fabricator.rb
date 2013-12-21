Fabricator(:member) do
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.paragraph }
  twitter { Faker::Name.first_name }
  auth_services(count: 1) { Fabricate(:auth_service) }
end

Fabricator(:student, from: :member) do
  roles { [ Fabricate(:student_role) ] }
end

Fabricator(:coach, from: :member) do
  roles { [ Role.find_by_name("Coach") || Fabricate(:coach_role) ] }
end

Fabricator(:admin, from: :member) do
  roles { [ Fabricate(:admin_role) ] }
end
