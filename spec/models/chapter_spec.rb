require 'spec_helper'

RSpec.describe Chapter, type: :model do
  subject(:chapter) { described_class.new }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:time_zone) }

    it do
      Fabricate(:chapter) 
      is_expected.to validate_uniqueness_of(:email)
    end

    it { is_expected.to validate_length_of(:description).is_at_most(280) }

    describe '#time_zone' do
      it 'denys an invalid time zone' do
        chapter.time_zone = 'Fake time'

        expect(chapter).not_to be_valid

        expect(chapter.errors[:time_zone]).to include('does not exist')
      end

      it 'allows a valid time zone' do
        chapter.time_zone = 'Eastern Time (US & Canada)'

        chapter.valid?

        expect(chapter.errors[:time_zone]).to_not include('does not exist')
      end
    end
  end

  describe '#slug' do
    it 'is defaulted to the name on save' do
      chapter = Fabricate.build(:chapter, name: 'London', slug: nil)

      chapter.save!

      expect(chapter.reload.slug).to eq('london')
    end

    it 'can be used as a URL' do
      chapter = Fabricate.build(:chapter, name: 'New York', slug: nil)

      chapter.save!

      expect(chapter.reload.slug).to eq('new-york')
    end
  end

  context 'scopes' do
    describe '#active' do
      it 'includes chapters with active flag' do
        active_chapter = Fabricate(:chapter, active: true)

        expect(Chapter.active).to include(active_chapter)
      end

      it 'excludes chapters without active flag' do
        inactive_chapter = Fabricate(:chapter, active: false)

        expect(Chapter.active).not_to include(inactive_chapter)
      end
    end
  end
end
