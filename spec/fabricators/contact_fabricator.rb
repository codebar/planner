Fabricator(:contact) do
  name { Faker::Name.name }
  surname { Faker::Name.name }
  email { Faker::Internet.email }
  mailing_list_consent { true }
  token { 'random-token' }
end
