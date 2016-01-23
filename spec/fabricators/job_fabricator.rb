Fabricator(:job) do
  title { Faker::Lorem.word }
  description { Faker::Lorem.paragraph }
  location { Faker::Address.city }
  email { Faker::Address.city }
  link_to_job { Faker::Internet.url }
  created_by { Fabricate(:member) }
  approved { true }
  submitted { true }
  expiry_date { Date.today+1.week }

end
