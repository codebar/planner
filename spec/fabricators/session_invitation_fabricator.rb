Fabricator(:session_invitation) do
  member
  attending nil
  attended nil
  note "I'd love to attend"
  sessions
  role "Student"
end

Fabricator(:attending_session_invitation, from: :session_invitation) do
  attending true
end

Fabricator(:attended_session_invitation, from: :attending_session_invitation) do
  attended true
end

Fabricator(:student_session_invitation, from: :session_invitation) do
  role "Student"
end

Fabricator(:coach_session_invitation, from: :session_invitation) do
  role "Coach"
end
