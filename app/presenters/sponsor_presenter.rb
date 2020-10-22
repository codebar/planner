class SponsorPresenter < BasePresenter
  include Rails.application.routes.url_helpers

  def self.decorate_collection(collection)
    collection.map { |e| SponsorPresenter.new(e) }
  end

  def address
    @address ||= model.address.present? ? AddressPresenter.new(model.address) : nil
  end

  def contact_info
    h.safe_join(contacts_details.flatten.compact)
  end

  def contacts_details
    return [] unless model.contacts.any?

    contacts.map do |c|
      details = "#{c.name} #{c.surname} (#{h.mail_to(c.email)}) #{mailing_list_status(c)}"
      h.content_tag(:li, h.raw(details))
    end
  end

  def sponsorships_count
    @sponsorships_count = workshops.count + sponsorships.count + meetings.count
  end

  private

  def h
    ActionController::Base.helpers
  end

  def mailing_list_status(contact)
    status_image = contact.mailing_list_consent? ? 'fa-bell' : 'fa-bell-slash'
    h.content_tag(:i, '', class: "fa #{status_image}")
  end
end
