Fabricator(:member) do
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.paragraph }
end

Fabricator(:student, from: :member) do
  roles { [ Fabricate(:student_role) ] }
end

Fabricator(:coach, from: :member) do
  roles { [ Fabricate(:coach_role) ] }
end
