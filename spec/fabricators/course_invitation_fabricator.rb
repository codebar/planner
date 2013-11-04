Fabricator(:course_invitation) do
  member
  attending false
  attended nil
  note "I'd love to attend"
  course
end
