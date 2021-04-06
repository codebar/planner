class EligibilityInquiry < ActiveRecord::Base
  belongs_to :member
  belongs_to :issued_by, class_name: 'Member', foreign_key: 'sent_by_id', inverse_of: false

  before_save :send_email

  private

  def send_email
    MemberMailer.eligibility_check(member, member.email).deliver_now
  end
end
