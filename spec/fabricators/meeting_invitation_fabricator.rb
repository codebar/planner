Fabricator(:meeting_invitation) do
  member
  attending false
  meeting
  role 'Student'
end

Fabricator(:attending_meeting_invitation, from: :meeting_invitation) do
  attending true
end

Fabricator(:banned_attending_meeting_invitation, from: :meeting_invitation) do
  member { Fabricate(:banned_member) }
  attending true
end
