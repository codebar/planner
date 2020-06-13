Fabricator(:workshop_sponsor) do
  workshop { Fabricate(:workshop_no_sponsor) }
  sponsor
  host false
end
