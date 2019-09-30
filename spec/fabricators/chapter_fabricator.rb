Fabricate.sequence(:name) { |i| "#{Faker::Lorem.word}#{i}" }

Fabricator(:chapter) do
  name { Fabricate.sequence(:name) }
  city { Faker::Address.city }
  email { Faker::Internet.email }
  slug { Faker::Internet.slug }
  twitter { Faker::Internet.url }
  time_zone { 'London' }

  after_save do |chapter|
    member = Fabricate(:member)
    member.add_role :organiser, chapter
  end
end

Fabricator(:chapter_with_groups, from: :chapter) do
  name { Fabricate.sequence(:name) }
  city { Faker::Lorem.word }
  email { Faker::Internet.email }
  time_zone { 'London' }

  after_save do |chapter|
    Fabricate(:students, chapter: chapter)
    Fabricate(:coaches, chapter: chapter)
  end
end

Fabricator(:chapter_without_organisers, class_name: :chapter) do
  name { Fabricate.sequence(:name) }
  city { Faker::Lorem.word }
  email { Faker::Internet.email }
  time_zone { 'London' }
end

Fabricator(:active_chapter, from: :chapter) do
  active true
end

Fabricator(:inactive_chapter, from: :chapter) do
  active false
end