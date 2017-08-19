titles = [
  'Junior Software Engineer',
  'Junior Software Developer',
  'Junior Front-end Developer',
  'Junior Back-end Developer',
  'Junior Full-stack Developer',
  'Software Engineer',
  'Software Developer',
  'Front-end Developer',
  'Back-end Developer',
  'Full-stack Developer'
]

companies = [
  'ACME',
  'Globex',
  'Soylent',
  'Initech',
  'Umbrella',
  'Wonka'
]

Fabricator(:job) do
  title { titles.sample }
  company { companies.sample }
  description { Faker::Lorem.paragraph }
  location { Faker::Address.city }
  email { Faker::Address.city }
  link_to_job { Faker::Internet.url }
  created_by { Fabricate(:member) }
  approved { true }
  submitted { true }
  expiry_date { Date.today+1.week }
end
