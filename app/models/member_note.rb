class MemberNote < ActiveRecord::Base
  belongs_to :member
  belongs_to :author, class_name: 'Member'

  validates :member, :author, :note, presence: true
end
