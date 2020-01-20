Fabricator(:member) do
  pronouns 'she/her'
  name { Faker::Name.first_name }
  surname { Faker::Name.last_name }
  email { Faker::Internet.email }
  about_you { Faker::Lorem.sentence }
  twitter { Faker::Name.first_name }
  auth_services(count: 1) { Fabricate(:auth_service) }
end

Fabricator(:member_with_toc, from: :member) do
  accepted_toc_at { Time.zone.now }
end

Fabricator(:student, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:students) }
end

Fabricator(:coach, from: :member) do
  groups(count: 2) { |attrs, i| Fabricate(:coaches) }
end

Fabricator(:banned_member, from: :member) do
  bans(count: 1) { Fabricate(:ban) }
end

Fabricator(:chapter_organiser, from: :member) do
  after_save do |member|
    chapter = Fabricate(:chapter)
    member.add_role :organiser, chapter
  end
end

Fabricator(:meeting_attendee, from: :member) do
  meeting_invitations(count: 1)
end

Fabricator(:workshop_coach_attendee, from: :member) do
  workshop_invitations(count: 1) { Fabricate(:attended_coach) }
end
