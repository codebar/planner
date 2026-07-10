RSpec.describe SponsorsSearch do
  describe 'initialization' do
    it 'configures its properties from the param hash' do
      search = described_class.new(name: 'Acme', chapter: 'London')

      expect(search.name).to eq('Acme')
      expect(search.chapter).to eq('London')
    end

    it 'handles nil params' do
      search = described_class.new(name: nil, chapter: nil)

      expect(search.name).to be_nil
      expect(search.chapter).to be_nil
    end
  end

  describe '#call' do
    it 'returns all sponsors when no filter is specified' do
      Fabricate.times(3, :sponsor)

      results = described_class.new(name: nil, chapter: nil).call

      expect(results.size).to eq(3)
      expect(results).to all(be_a(Sponsor))
    end

    it 'filters by name' do
      matching = Fabricate(:sponsor, name: 'Zebra Technologies')
      Fabricate(:sponsor, name: 'Apple Inc')

      results = described_class.new(name: 'Zebra', chapter: nil).call

      expect(results).to contain_exactly(matching)
    end

    it 'is case insensitive when filtering by name' do
      matching = Fabricate(:sponsor, name: 'Zebra Technologies')

      results = described_class.new(name: 'zebra', chapter: nil).call
      expect(results).to contain_exactly(matching)

      results = described_class.new(name: 'ZEBRA', chapter: nil).call
      expect(results).to contain_exactly(matching)
    end

    it 'filters by chapter' do
      chapter = Fabricate(:chapter)
      matching = Fabricate(:sponsor)
      Fabricate(:workshop_sponsor, workshop: Fabricate(:workshop_no_sponsor, chapter: chapter), sponsor: matching)
      Fabricate(:sponsor)

      results = described_class.new(name: nil, chapter: chapter.id.to_s).call

      expect(results).to contain_exactly(matching)
    end

    it 'filters by name and chapter combined' do
      chapter = Fabricate(:chapter)
      matching = Fabricate(:sponsor, name: 'Zebra Technologies')
      Fabricate(:workshop_sponsor, workshop: Fabricate(:workshop_no_sponsor, chapter: chapter), sponsor: matching)
      Fabricate(:sponsor, name: 'Zebra Technologies')
      Fabricate(:sponsor, name: 'Apple Inc')

      results = described_class.new(name: 'Zebra', chapter: chapter.id.to_s).call

      expect(results).to contain_exactly(matching)
    end

    it 'returns an empty relation when nothing matches' do
      Fabricate(:sponsor, name: 'Apple Inc')

      results = described_class.new(name: 'Nonexistent', chapter: nil).call

      expect(results).to be_empty
    end
  end
end
