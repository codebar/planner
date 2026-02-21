class MeetingInvitation < ApplicationRecord
  include InvitationConcerns

  belongs_to :meeting
  belongs_to :member

  validates :meeting, :member, presence: true
  validates :member_id, uniqueness: { scope: [:meeting_id] }

  scope :accepted, -> { where(attending: true) }
  scope :attended, -> { where(attended: true) }

  after_save :clear_member_cache, if: :saved_change_to_attending?

  alias event meeting

  private

  def clear_member_cache
    member.clear_attending_event_ids_cache!
  end
end
