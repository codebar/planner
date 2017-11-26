# avatars = [
#   "https://placekitten.com/200/101",
#   "https://placekitten.com/200/102",
#   "https://placekitten.com/200/103",
#   "https://placekitten.com/200/104"
# ]

Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { "http://#{Faker::Internet.domain_name}" }
  avatar { Rack::Test::UploadedFile.new(Rails.root.join('app', 'assets', 'images', 'logo.png'), 'image/jpeg') }
  address
  email { Faker::Internet.email }
  contact_first_name { Faker::Name.first_name }
  contact_surname { Faker::Name.last_name }
end
