require 'spec_helper'

describe AddressDecorator do
  let(:address) { Fabricate.build(:address).decorate }

  it '#to_html' do
    html_address = "#{address.flat}<br/>#{address.street}<br/>#{address.city}, #{address.postal_code}"

    expect(address.to_html).to eq(html_address)
  end

  it '#to_s' do
    address_to_s = "#{address.flat}, #{address.street}, #{address.city}, #{address.postal_code}"

    expect(address.to_s).to eq(address_to_s)
  end
end
