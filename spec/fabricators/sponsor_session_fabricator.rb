Fabricator(:sponsor_session) do
  sponsor
  sessions
end

Fabricator(:hosted_session, from: :sponsor_session) do
  host true
end