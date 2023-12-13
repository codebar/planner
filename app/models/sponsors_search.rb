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
    @sponsors = sponsors.joins(:workshops).where('workshops.chapter_id' => chapter) if chapter.present?
  end
end
