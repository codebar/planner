Fabricator(:feedback_request) do
  member
  workshop
  token { 'valid_token' }
  submited { false }
end
