require 'services/mailing_list'
class Contact < ApplicationRecord
  belongs_to :sponsor

  validates :name, :surname, :email, presence: true

  before_create :set_token
  after_commit :subscribe_to_mailing_list, if: proc { |c| c.mailing_list_consent }
  after_commit :unsubscribe_from_mailing_list, if: proc { |c| !c.mailing_list_consent }

  def subscribe_to_mailing_list
    mailing_list.subscribe(email, name, surname)
    ContactMailer.subscription_notification(self).deliver
  end

  def unsubscribe_from_mailing_list
    mailing_list.unsubscribe(email)
  end

  def mailing_list
    @mailing_list ||= MailingList.new(ENV['SPONSOR_NEWSLETTER_ID'])
  end

  private

  def set_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.where(token: random_token).exists?
    end
  end
end
