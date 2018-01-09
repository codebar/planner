class MemberContact < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :contact, class_name: 'Member', foreign_key: 'member_id'
end
