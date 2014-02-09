Fabricator(:feedback_request) do
  member
  sessions
  token { 'valid_token' }
  submited { false }
end