Fabricator(:member) do
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.paragraph }
end
