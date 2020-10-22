class ContactPresenter < BasePresenter
  def self.decorate_collection(collection)
    collection.map { |e| ContactPresenter.new(e) }
  end

  def full_name
    "#{name} #{surname}"
  end

  def mailing_list_subscription_class
    mailing_list_consent? ? 'fa-bell' : 'fa-bell-slash'
  end
end
