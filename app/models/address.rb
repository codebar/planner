class Address < ActiveRecord::Base
  belongs_to :sponsor

  validates :sponsor_id, presence: true
end