class Job < ActiveRecord::Base
  self.per_page = 10

  enum status: { draft: 0, pending: 1, published: 2 }

  belongs_to :created_by, class_name: 'Member'
  belongs_to :approved_by, class_name: 'Member'

  scope :pending_or_published, -> { where(status: [statuses[:pending], statuses[:published]]) }
  scope :ordered, -> { order('created_at desc') }
  scope :owner_order, -> { order(published_on: :desc, created_at: :desc) }
  scope :active, -> { where('expiry_date > ?', Time.zone.today) }

  validates :title, :company, :location, :description, :link_to_job, :expiry_date, presence: true

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def approve!(approver)
    update(approved: true,
           approved_by_id: approver.id,
           published_on: Time.zone.now)
    published!
  end

  def unpublish!
    update(approved: false,
           approved_by_id: nil,
           published_on: nil)
    pending!
  end

  def expired?
    expiry_date.past?
  end

  def slug_candidates
    [
      :title,
      %w[title company],
      %w[title company location]
    ]
  end
end
