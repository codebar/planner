RSpec.describe Chapter do
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_length_of(:description).is_at_most(280) }

  context 'validations' do
    describe '#slug' do
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

    describe '#time_zone' do
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
    describe '#active' do
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

  describe '#eligible_students' do
    let(:chapter) { Fabricate(:chapter) }
    let(:student_group) { Fabricate(:group, chapter: chapter, name: 'Students') }

    it 'includes only students with accepted TOC who are not banned' do
      eligible_student = Fabricate(:member, groups: [student_group], accepted_toc_at: Time.zone.now)
      _ineligible_no_toc = Fabricate(:member, groups: [student_group], accepted_toc_at: nil)
      _ineligible_banned = Fabricate(:banned_member, groups: [student_group], accepted_toc_at: Time.zone.now)

      expect(chapter.eligible_students).to contain_exactly(eligible_student)
    end

    it 'returns empty relation when no eligible students' do
      Fabricate(:member, groups: [student_group], accepted_toc_at: nil)
      expect(chapter.eligible_students).to be_empty
    end
  end

  describe '#eligible_coaches' do
    let(:chapter) { Fabricate(:chapter) }
    let(:coach_group) { Fabricate(:group, chapter: chapter, name: 'Coaches') }

    it 'includes only coaches with accepted TOC who are not banned' do
      eligible_coach = Fabricate(:member, groups: [coach_group], accepted_toc_at: Time.zone.now)
      _ineligible_no_toc = Fabricate(:member, groups: [coach_group], accepted_toc_at: nil)
      _ineligible_banned = Fabricate(:banned_member, groups: [coach_group], accepted_toc_at: Time.zone.now)

      expect(chapter.eligible_coaches).to contain_exactly(eligible_coach)
    end

    it 'returns empty relation when no eligible coaches' do
      Fabricate(:member, groups: [coach_group], accepted_toc_at: nil)
      expect(chapter.eligible_coaches).to be_empty
    end
  end
end
