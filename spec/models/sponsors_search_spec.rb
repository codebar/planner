require 'spec_helper'

RSpec.describe SponsorsSearch, type: :model do
  let(:search_params) { { per_page: 5, page: 2, name: Faker::Name.name } }

  describe 'initialization params' do
    it 'configures its properties using the param hash' do
      params = { per_page: 5, page: 2, name: Faker::Name.name }

      sponsors_search = described_class.new(search_params)

      expect(sponsors_search.page).to eq(search_params[:page])
      expect(sponsors_search.per_page).to eq(search_params[:per_page])
      expect(sponsors_search.name).to eq(search_params[:name])
    end
  end

  describe 'when search is called' do
    it 'searches by_name if a name is specified' do
      expect(Sponsor).to receive(:by_name)

      described_class.new(search_params).call
    end

    it 'returns all sponsors when no filter is specified' do
      expect(Sponsor).to_not receive(:by_name)

      described_class.new({ name: nil}).call
    end
  end
end
