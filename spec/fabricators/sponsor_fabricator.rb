avatars = [
  "https://dl.dropboxusercontent.com/u/108831317/pug1.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug2.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug3.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug4.png" ]

Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { "http://#{Faker::Internet.domain_name}" }
  avatar { avatars.sample }
  address
  email { Faker::Internet.email }
  contact_first_name { Faker::Name.first_name }
  contact_surname { Faker::Name.last_name }
end
