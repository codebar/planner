
Fabricator(:job) do
  title 'Software Developer'
  company 'ACME'
  description { Faker::Lorem.paragraph }
  location { Faker::Address.city }
  email { Faker::Address.city }
  link_to_job { Faker::Internet.url }
  created_by { Fabricate(:member) }
  approved { true }
  submitted { true }
  expiry_date { Time.zone.today + 1.week }
end
