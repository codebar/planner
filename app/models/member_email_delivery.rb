class MemberEmailDelivery < ApplicationRecord
  belongs_to :member, polymorphic: true, optional: true
end
