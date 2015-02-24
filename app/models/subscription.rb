class Subscription < ActiveRecord::Base
  belongs_to :group
  belongs_to :member

  validates_uniqueness_of :group, scope: :member_id
  default_scope -> { order(:created_at) }

  after_create :subscribe_to_mailing_list
  after_destroy :unsubscribe_from_mailing_list

  def student?
    group.name.downcase == "students"
  end

  def coach?
    group.name.downcase == "coaches"
  end

  private

  def subscribe_to_mailing_list
    MailingList.new(group.mailing_list_id).subscribe(member.email, member.name, member.surname)
  end

  def unsubscribe_from_mailing_list
    MailingList.new(group.mailing_list_id).unsubscribe(member.email)
  end
end
