class MemberContact < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :member
end
