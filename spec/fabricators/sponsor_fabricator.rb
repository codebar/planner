avatars = [
  "spec/support/images/pug1.png",
  "spec/support/images/pug2.png",
  "spec/support/images/pug3.png",
  "spec/support/images/pug4.png"
]

Fabricator(:sponsor) do
  name { Faker::Name.name }
  website { "http://#{Faker::Internet.domain_name}" }
  avatar { 
    file = File.new(Rails.root.join(avatars.sample))
    ActionDispatch::Http::UploadedFile.new(
      :tempfile => file,
      :filename => File.basename(file)
    )
  }
  address
  email { Faker::Internet.email }
  contact_first_name { Faker::Name.first_name }
  contact_surname { Faker::Name.last_name }
end
