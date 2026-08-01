class AddressPresenter < BasePresenter
  def to_html
    lat = model.latitude.present? ? "Latitude: #{model.latitude}" : ''
    lng = model.longitude.present? ? "Longitude: #{model.longitude}" : ''
    city_and_postal_code = [model.city, model.postal_code].delete_if(&:empty?)
                                                          .join(', ')

    # Every element is html_escape'd; `.html_safe` prevents Rails double-escaping the joined string
    # rubocop:disable Rails/OutputSafety
    [model.flat, model.street, city_and_postal_code, lat, lng]
      .delete_if(&:empty?)
      .map { |line| ERB::Util.html_escape(line) }
      .join('<br/>').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def for_map
    if model.latitude.present? && model.longitude.present?
      [latitude, longitude].join(',')
    else
      [model.flat, model.street, model.city, model.postal_code].delete_if(&:empty?).join(',+')
    end
  end

  def to_s
    [model.flat, model.street, model.city, model.postal_code].delete_if(&:empty?).join(', ')
  end
end
