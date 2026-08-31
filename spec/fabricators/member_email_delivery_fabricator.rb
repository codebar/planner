Fabricator(:member_email_delivery) do
  member(fabricator: :member)
  email_type('chaser')
  subject('Chaser')
  body('Lorem ipsum')
  to(['test_email@address'])
end
