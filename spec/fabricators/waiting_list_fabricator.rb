Fabricator(:waiting_list) do
  invitation { Fabricate(:session_invitation) }
end
