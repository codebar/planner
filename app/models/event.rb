class Event < ActiveRecord::Base
  include Listable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  belongs_to :venue, class: Sponsor
  has_many :sponsorships
  has_many :sponsors, through: :sponsorships

  def to_s
    self.name
  end

  def to_param
    self.slug
  end

end
