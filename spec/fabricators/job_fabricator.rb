Fabricator(:job) do
  title { Faker::Job.title }
  company { Faker::Company.name }
  description { Faker::Lorem.paragraph(sentence_count: 7) }
  location { Faker::Address.city }
  email { Faker::Address.city }
  link_to_job { Faker::Internet.url }
  created_by { Fabricate(:member) }
  approved { true }
  submitted { false }
  expiry_date { Time.zone.today + 1.week }
  status :draft
  company_website { Faker::Internet.url }
end

Fabricator(:published_job, from: :job) do
  published_on { Time.zone.yesterday }
  submitted { true }
  status :published
end

Fabricator(:pending_job, from: :job) do
  approved { false }
  submitted { true }
  status :pending
end
