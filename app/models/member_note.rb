class MemberNote < ApplicationRecord
  belongs_to :member
  belongs_to :author, class_name: 'Member'

  validates :member, :author, :note, presence: true
end
