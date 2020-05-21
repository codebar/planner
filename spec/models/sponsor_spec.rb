require 'spec_helper'

RSpec.describe Sponsor, type: :model do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:avatar) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_presence_of(:seats) }

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
        .with_values(%i[hidden standard bronze silver gold])
    end
  end

  context '#contacts' do
    it 'returns the members set as contacts for the sponsor' do
      members = Fabricate.times(2, :member)
      members.each { |m| Fabricate(:member_contact, sponsor: sponsor, contact: m) }

      expect(sponsor.contacts).to include(*members)
    end
  end
end
