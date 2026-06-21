class EligibilityInquiry < ApplicationRecord
  belongs_to :member
  belongs_to :issued_by, class_name: 'Member', foreign_key: 'sent_by_id', inverse_of: false
end
