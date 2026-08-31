class MemberEmailDelivery < ApplicationRecord
  self.ignored_columns += ['member_type']

  belongs_to :member
end
