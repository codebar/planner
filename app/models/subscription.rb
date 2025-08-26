require 'services/mailing_list'

class Subscription < ApplicationRecord
  belongs_to :group
  belongs_to :member
  has_one :chapter, through: :group

  validates :group, uniqueness: { scope: :member_id }
  scope :ordered, -> { order(created_at: :desc) }

  after_create :subscribe_to_mailing_list
  after_destroy :unsubscribe_from_mailing_list

  def student?
    group.name.casecmp('students').zero?
  end

  def coach?
    group.name.casecmp('coaches').zero?
  end

  private

  def subscribe_to_mailing_list
    Services::MailingList.new(group.mailing_list_id).subscribe(member.email, member.name, member.surname)
  end

  def unsubscribe_from_mailing_list
    Services::MailingList.new(group.mailing_list_id).unsubscribe(member.email)
  end
end
