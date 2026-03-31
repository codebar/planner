Fabricator(:invitation_log_entry) do
  invitation_log
  member
  status 'success'
  processed_at { Time.current }
end
