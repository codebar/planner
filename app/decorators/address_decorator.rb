class AddressDecorator < Draper::Decorator
  delegate_all

  def to_html
    lat = latitude.present? ? "Latitude: #{latitude}" : nil
    lng =  longitude.present? ? "Longitude: #{longitude}" : nil

    [ flat, street, "#{city}, #{postal_code}", lat, lng ]
      .compact.delete_if(&:empty?).join("<br/>").html_safe
  end

  def for_map
    if latitude.present? && longitude.present?
      [latitude,longitude].join(",")
    else
      [ flat, street, city, postal_code ].delete_if(&:empty?).join(",+")
    end
  end

  def to_s
    [ flat, street, city, postal_code ].delete_if(&:empty?).join(", ")
  end
end
