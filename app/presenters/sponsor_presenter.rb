class SponsorPresenter < BasePresenter
  def self.decorate_collection(collection)
    collection.map { |e| SponsorPresenter.new(e) }
  end

  def address
    @address ||= model.address.present? ? AddressPresenter.new(model.address) : nil
  end

  def contacts
    @contacts ||= ContactPresenter.decorate_collection(model.contacts)
  end

  def sponsorships_count
    @sponsorships_count = workshops.count + sponsorships.count + meetings.count
  end
end
