class Job < ActiveRecord::Base
  belongs_to :created_by, class_name: 'Member', foreign_key: :created_by_id
  belongs_to :approved_by, class_name: 'Member', foreign_key: :approved_by_id

  scope :approved, -> { where(approved: true) }
  scope :submitted, -> { where(submitted: true, approved: false) }
  scope :not_submitted, -> { where(submitted: false, approved: false) }

  scope :ordered, -> { order('created_at desc') }
  default_scope -> { where('expiry_date > ?', Time.zone.today) }

  def expired?
    self.expiry_date.past?
  end
end
