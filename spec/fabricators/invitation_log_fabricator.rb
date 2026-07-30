Fabricator(:invitation_log) do
  loggable { Fabricate(:workshop) }
  initiator { Fabricate(:member) }
  audience 'students'
  action 'invite'
  status 'running'
  chapter_id { |attrs| attrs[:loggable].try(:chapter_id) }
end
