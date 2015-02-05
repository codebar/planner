Fabricator(:member_note) do
  member
  author(fabricator: :member)
  note { Faker::Lorem.paragraph }
end
