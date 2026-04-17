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

  describe "helper methods return only that chapter's coaches/students" do
    RSpec.shared_examples 'group-scoped members' do |group_name, method_name|
      let(:this_chapter) { Fabricate(:chapter) }
      let(:that_chapter) { Fabricate(:chapter) }

      let!(:this_group)  { Fabricate(:group, chapter: this_chapter, name: group_name) }
      let!(:that_group)  { Fabricate(:group, chapter: that_chapter, name: group_name) }

      let!(:this_member) { Fabricate(:member) }
      let!(:that_member) { Fabricate(:member) }

      before do
        Fabricate(:subscription, group: this_group, member: this_member)
        Fabricate(:subscription, group: that_group, member: that_member)
      end

      it "returns only #{group_name.downcase} for the chapter" do
        expect(this_chapter.public_send(method_name))
          .to contain_exactly(this_member)
      end

      it "does not include #{group_name.downcase} from another chapter" do
        expect(this_chapter.public_send(method_name))
          .not_to include(that_member)
      end
    end
  end
end
