Fabricator(:invitation_log) do
  loggable { Fabricate(:workshop) }
  initiator { Fabricate(:member) }
  audience 'students'
  action 'invite'
  status 'running'
end
