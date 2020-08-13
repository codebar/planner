# avatars = [
#   "https://placekitten.com/200/101",
#   "https://placekitten.com/200/102",
#   "https://placekitten.com/200/103",
#   "https://placekitten.com/200/104"
# ]

Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { "http://#{Faker::Internet.domain_name}" }
  avatar { Rack::Test::UploadedFile.new(Rails.root.join('app', 'assets', 'images', 'sponsors', sponsor_image), 'image/jpeg') }
  address
  email { Faker::Internet.email }
  contact_first_name { Faker::Name.first_name }
  contact_surname { Faker::Name.last_name }
end

Fabricator(:sponsor_full, from: :sponsor) do
  description { Faker::Lorem.word }
  level { 'gold' }
end

Fabricator(:sponsor_with_contacts, from: :sponsor) do
  after_build do |sponsor, transients|
    Fabricate(:contact,
              sponsor: sponsor)
  end
end

def sponsor_image
  "#{%w[8th-Light StreetTeam bloomberg gds-logo mozilla pivotal shutl_logo softwire the-guardian ticketmaster ustwo].sample}.png"
end
