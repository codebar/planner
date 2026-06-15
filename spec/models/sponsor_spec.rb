RSpec.describe Sponsor do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:avatar) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:number_of_coaches) }
    it { is_expected.to validate_presence_of(:seats) }
    it { is_expected.to validate_numericality_of(:number_of_coaches).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:seats).is_greater_than_or_equal_to(0).only_integer }

    context 'scopes' do
      describe 'searching by_name' do
        let!(:search_sponsor) { Fabricate(:sponsor, name: 'codebar') }
        before do
          Fabricate.times(2, :sponsor)
        end

        it 'matches on any part of the name' do
          results = Sponsor.by_name('debar')

          expect(results.count).to eq(1)
        end

        it 'is not case sensitive' do
          results = Sponsor.by_name('CODEBAR')

          expect(results.count).to eq(1)
        end
      end
    end

    context '#website_is_url format' do
      it 'allows full URLs' do
        sponsor.website = 'http://google.com'

        sponsor.valid?

        expect(sponsor.errors[:website]).to_not include('must be a full, valid URL')
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
      is_expected.to define_enum_for(:level)
        .with_values(%i[hidden standard bronze silver gold community])
    end
  end
end
