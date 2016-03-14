Fabricator(:ban) do
  reason "Violation of attendance policy"
  note Faker::Lorem.word
  expires_at Date.today+1.month
  added_by { Fabricate(:member) }

end
