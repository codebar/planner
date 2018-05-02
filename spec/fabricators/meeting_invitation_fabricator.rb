Fabricator(:meeting_invitation) do
  member
  attending false
  meeting
  role 'Student'
end

Fabricator(:attending_meeting_invitation, from: :meeting_invitation) do
  attending true
end
