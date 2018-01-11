Fabricator(:member) do
  pronouns 'she/her'
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.sentence }
  twitter { Faker::Name.first_name }
  auth_services(count: 1) { Fabricate(:auth_service) }
end

Fabricator(:student, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:students) }
end

Fabricator(:coach, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:coaches) }
end

Fabricator(:chapter_organiser, from: :member) do
  after_save do |member|
    chapter = Fabricate(:chapter)
    member.add_role :organiser, chapter
  end
end
