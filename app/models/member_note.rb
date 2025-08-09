class MemberNote < ApplicationRecord
  belongs_to :member, optional: true
  belongs_to :author, class_name: 'Member', optional: true

  validates :member, :author, :note, presence: true
end
