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
  reminded_at nil
end

Fabricator(:attended_workshop_invitation, from: :workshop_invitation) do
  attended true
end

Fabricator(:student_workshop_invitation, from: :workshop_invitation) do
  role 'Student'
end

Fabricator(:coach_workshop_invitation, from: :workshop_invitation) do
  role 'Coach'
  note nil
end

Fabricator(:attended_coach, from: :workshop_invitation) do
  role 'Coach'
  attended true
  note nil
end

Fabricator(:waitinglist_invitation, from: :workshop_invitation) do
  waiting_list
  reminded_at nil
end

Fabricator(:waitinglist_invitation_reminded, from: :workshop_invitation) do
  waiting_list
  reminded_at 2.days.ago
end
