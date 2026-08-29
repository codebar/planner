class SponsorsSearch
  include ActiveModel::Model

  attr_accessor :name, :chapter

  def initialize(params = {})
    @name = params.fetch(:name)
    @chapter = params.fetch(:chapter)
  end

  def call
    by_name
    by_chapter
    sponsors
  end

  private

  def sponsors
    # Get rid of unsafe SQL warning
    @sponsors ||= Sponsor.includes(:chapters).reorder(Arel.sql('lower(sponsors.name)'))
  end

  def by_name
    @sponsors = sponsors.by_name(name) if name.present?
  end

  def by_chapter
    return if chapter.blank?

    chapter_id = chapter.to_s.match?(/\A\d+\z/) ? chapter : lookup_chapter_id
    if chapter_id
      @sponsors = sponsors.joins(:workshops).where('workshops.chapter_id' => chapter_id).group('sponsors.id')
    else
      errors.add(:chapter, :not_found, message: 'no chapter with that name')
      @sponsors = Sponsor.none
    end
  end

  def lookup_chapter_id
    Chapter.find_by('LOWER(name) = LOWER(?)', chapter.strip)&.id
  end
end
