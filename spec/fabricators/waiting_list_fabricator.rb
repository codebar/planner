Fabricator(:waiting_list) do
  invitation { Fabricate(:workshop_invitation) }
end
