class WorkshopWorkingGroup < ApplicationRecord
  belongs_to :workshop
  has_many :workshop_invitation_working_groups, dependent: :destroy
  has_many :workshop_invitations, through: :workshop_invitation_working_groups

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(:position, :id) }
end
