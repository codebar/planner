class Chapter < ActiveRecord::Base
  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  validates :name, :email, uniqueness: true, presence: true
  validates  :city, presence: true

  has_many :workshops, class_name: Sessions
  has_many :groups
  has_many :sponsors, through: :workshops

  def organisers
    @organisers ||= Member.with_role(:organiser, self)
  end
end
