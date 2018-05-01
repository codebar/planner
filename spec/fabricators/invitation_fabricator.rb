Fabricator(:invitation) do
  member
  attending false
  note "I'd love to attend"
  event
  role 'Student'
end

Fabricator(:coach_invitation, from: :invitation) do
  role 'Coach'
end

Fabricator(:attending_event_invitation, from: :invitation) do
  attending true
end
