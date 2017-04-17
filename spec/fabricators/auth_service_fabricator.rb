Fabricator(:auth_service) do
  provider "github"
  uid { Fabricate.sequence(:uid) { |i| i.to_s } }
end
