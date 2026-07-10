RSpec.describe SponsorsSearch do
  describe 'initialization' do
    it 'configures its properties from the param hash' do
      search = described_class.new(name: 'Acme', chapter: 'London')

      expect(search.name).to eq('Acme')
      expect(search.chapter).to eq('London')
    end
  end

  describe 'when search is called' do
    it 'searches by_name if a name is specified' do
      expect(Sponsor).to receive(:by_name)

      described_class.new(name: 'Acme', chapter: 'London').call
    end

    it 'returns all sponsors when no filter is specified' do
      expect(Sponsor).to_not receive(:by_name)

      described_class.new(name: nil, chapter: nil).call
    end
  end
end
