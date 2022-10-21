class SponsorsSearch
  include ActiveModel::Model

  attr_accessor :name, :page, :per_page, :chapter

  def initialize(params = {})
    @page = params.fetch(:page, 1)
    @per_page = params.fetch(:per_page, Sponsor.per_page)
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
    @sponsors ||= Sponsor.includes([:chapters]).reorder('lower(sponsors.name)').paginate(page: page)
  end

  def by_name
    @sponsors = sponsors.by_name(name) if name.present?
  end

  def by_chapter
    @sponsors = sponsors.joins(:workshops).where('workshops.chapter_id' => chapter) if chapter.present?
  end
end
