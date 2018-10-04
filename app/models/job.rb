class Job < ActiveRecord::Base
  belongs_to :created_by, class_name: 'Member', foreign_key: :created_by_id
  belongs_to :approved_by, class_name: 'Member', foreign_key: :approved_by_id

  scope :approved, -> { where(approved: true) }
  scope :submitted, -> { where(submitted: true, approved: false) }
  scope :not_submitted, -> { where(submitted: false, approved: false) }

  scope :ordered, -> { order('created_at desc') }
  scope :active, -> { where('expiry_date > ?', Time.zone.today) }

  validates :title, :company, :location, :description, :link_to_job, :expiry_date, presence: true

  def approve!(approver)
    update(approved: true,
           approved_by_id: approver.id,
           published_on: Time.zone.now)
  end

  def expired?
    self.expiry_date.past?
  end

  def status
    return :draft if submitted.eql?(false) && approved.eql?(false)
    return :pending if submitted.eql?(true) && approved.eql?(false)
    return :expired if expiry_date.past?
    return :published if submitted.eql?(true) && approved.eql?(true)
  end

  def slug_candidates
    [
      :title,
      %[title company],
      %w[title company location]
    ]
  end
end
