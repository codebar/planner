Fabricator(:member_email_delivery) do
  member(fabricator: :member)
  subject("Chaser")
  body("Lorem ipsum")
  to(["test_email@address"])
end
