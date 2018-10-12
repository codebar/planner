Fabricator(:job) do
  title { Faker::Job.title }
  company { Faker::Company.name }
  description { Faker::Lorem.paragraph(7) }
  location { Faker::Address.city }
  email { Faker::Address.city }
  link_to_job { Faker::Internet.url }
  created_by { Fabricate(:member) }
  approved { true }
  submitted { true }
  expiry_date { Time.zone.today + 1.week }
end

Fabricator(:published_job, from: :job) do
  published_on { Time.zone.yesterday }
end

Fabricator(:pending_job, from: :job) do
  approved { false }
end
