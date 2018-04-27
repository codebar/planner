Fabricator(:workshop_invitation) do
  member
  attending nil
  attended nil
  note { Faker::Lorem.word }
  workshop
  role 'Student'
end

Fabricator(:attending_workshop_invitation, from: :workshop_invitation) do
  attending true
end

Fabricator(:attended_workshop_invitation, from: :workshop_invitation) do
  attended true
end

Fabricator(:student_workshop_invitation, from: :workshop_invitation) do
  role 'Student'
end

Fabricator(:coach_workshop_invitation, from: :workshop_invitation) do
  role 'Coach'
end
