class AddressPresenter < BasePresenter
  def to_html
    lat = model.latitude.present? ? "Latitude: #{model.latitude}" : ''
    lng = model.longitude.present? ? "Longitude: #{model.longitude}" : ''
    city_and_postal_code = [model.city, model.postal_code].delete_if(&:empty?)
                                                          .join(', ')

    [model.flat, model.street, city_and_postal_code, lat, lng]
      .delete_if(&:empty?).join('<br/>').html_safe
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
