Fabricator(:role) do
end

Fabricator(:student_role, from: :role) do
  name "Student"
end

Fabricator(:coach_role, from: :role) do
  name "Coach"
end
