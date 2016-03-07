Fabricator(:workshop) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  after_build do |workshop|
    Fabricate(:workshop_sponsor, workshop: workshop, sponsor: Fabricate(:sponsor), host: true )
  end
end

Fabricator(:workshop_no_sponsor, class_name: :workshop) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
end

Fabricator(:workshop_no_spots, class_name: :workshop) do
  date_and_time Time.zone.now+2.days
  time Time.zone.now
  title Faker::Lorem.sentence
  description Faker::Lorem.sentence
  chapter
  after_build do |workshop|
    Fabricate(:workshop_sponsor, workshop: workshop, sponsor: Fabricate(:sponsor, seats: 0), host: true )
  end
end
