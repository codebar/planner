RSpec.describe Sponsor do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  context 'with validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:avatar) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:number_of_coaches) }
    it { is_expected.to validate_presence_of(:seats) }
    it { is_expected.to validate_numericality_of(:number_of_coaches).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:seats).is_greater_than_or_equal_to(0).only_integer }

    context 'with scopes' do
      describe 'searching by_name' do
        before do
          Fabricate(:sponsor, name: 'codebar')
          Fabricate.times(2, :sponsor)
        end

        it 'matches on any part of the name' do
          results = described_class.by_name('debar')

          expect(results.count).to eq(1)
        end

        it 'is not case sensitive' do
          results = described_class.by_name('CODEBAR')

          expect(results.count).to eq(1)
        end
      end
    end

    describe '#website_is_url format' do
      it 'allows full URLs' do
        sponsor.website = 'http://google.com'

        sponsor.valid?

        expect(sponsor.errors[:website]).not_to include('must be a full, valid URL')
      end

      it 'does not allow nonsense' do
        sponsor.website = 'lkjdlkfgjj'

        sponsor.valid?

        expect(sponsor.errors[:website]).to include('must be a full, valid URL')
      end

      it 'must have a protocol' do
        sponsor.website = 'www.google.com'

        sponsor.valid?

        expect(sponsor.errors[:website]).to include('must be a full, valid URL')
      end
    end

    it 'defines enum level' do
      expect(sponsor).to define_enum_for(:level)
        .with_values(%i[hidden standard bronze silver gold community])
    end
  end
end
