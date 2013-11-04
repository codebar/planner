Fabricator(:session_invitation) do
  member
  attending false
  attended nil
  note "I'd love to attend"
  sessions
end
