Fabricator(:chapter) do |chapter|
  name { sequence(:name) { |i| "#{Faker::Lorem.word}-#{i}" } }
  city { Faker::Lorem.word }
end


