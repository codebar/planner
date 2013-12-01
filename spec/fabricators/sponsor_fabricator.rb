avatars = [
  "https://dl.dropboxusercontent.com/u/108831317/pug1.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug2.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug3.png",
  "https://dl.dropboxusercontent.com/u/108831317/pug4.png" ]

Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { Faker::Internet.domain_name }
  avatar { avatars.sample }
  address { Fabricate(:address) }
end

