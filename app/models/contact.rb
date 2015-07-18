class Contact < ActiveRecord::Base
  belongs_to :member
  belongs_to :sponsor
end
