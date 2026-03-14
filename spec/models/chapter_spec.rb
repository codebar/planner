RSpec.describe Chapter do
  it { should validate_presence_of(:city) }
  it { should validate_length_of(:description).is_at_most(280) }

  context 'validations' do
    context '#slug' do
      it 'a chapter must have a slug set' do
        chapter = Chapter.new(name: 'London', city: 'London', email: 'london@codebar.io')
        chapter.save

        expect(chapter.slug).to eq('london')
      end

      it 'the slug is parameterized' do
        chapter = Chapter.new(name: 'New York', city: 'New York', email: 'newyork@codebar.io')
        chapter.save

        expect(chapter.slug).to eq('new-york')
      end
    end

    context '#time_zone' do
      it 'requires a time zone' do
        chapter = Fabricate(:chapter)
        expect(chapter).to be_valid
        chapter.time_zone = nil
        expect(chapter).not_to be_valid
        chapter.time_zone = 'Fake time'
        expect(chapter).not_to be_valid
      end
    end
  end

  context 'scopes' do
    context '#active' do
      it 'only returns active Chapters' do
        1.times { Fabricate(:chapter) }
        2.times { Fabricate(:chapter, active: false) }

        expect(Chapter.active.all.count).to eq(1)
      end
    end
  end

  context 'cache expiration' do
    let(:cache_key) { 'chapters-sidebar' }

    it 'expires cache when chapter is created' do
      Rails.cache.write(cache_key, 'cached content')
      Fabricate(:chapter)
      expect(Rails.cache.read(cache_key)).to be_nil
    end

    it 'expires cache when chapter is updated' do
      Rails.cache.write(cache_key, 'cached content')
      chapter = Fabricate(:chapter)
      chapter.update!(name: 'Updated Name')
      expect(Rails.cache.read(cache_key)).to be_nil
    end

    it 'expires cache when chapter is destroyed' do
      Rails.cache.write(cache_key, 'cached content')
      chapter = Fabricate(:chapter)
      chapter.destroy
      expect(Rails.cache.read(cache_key)).to be_nil
    end
  end
end
