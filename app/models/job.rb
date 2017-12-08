class Job < ActiveRecord::Base
  belongs_to :created_by, class_name: "Member", foreign_key: :created_by_id
  belongs_to :approved_by, class_name: "Member", foreign_key: :approved_by_id
  belongs_to :archived_by, class_name: "Member", foreign_key: :archived_by_id

  scope :approved, -> { where(approved: true) }
  scope :archived, -> { where(archived: true) }
  #scope :not_archived, -> { where(archived: false) }
  scope :submitted, -> { where(submitted: true, approved: false, archived: false) }
  scope :not_submitted, -> { where(submitted: false, approved: false) }

  scope :ordered, -> { order('created_at desc') }
  default_scope -> { where('expiry_date > ?', Date.today) }

  def expired?
    self.expiry_date.past?
  end

end
