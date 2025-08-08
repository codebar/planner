class Address < ApplicationRecord
  belongs_to :sponsor, optional: true
end
