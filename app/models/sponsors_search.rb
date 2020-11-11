class SponsorsSearch
  include ActiveModel::Model

  attr_accessor :name, :page, :per_page

  def initialize(params = {})
    @page = params.fetch(:page, 1)
    @per_page = params.fetch(:per_page, Sponsor.per_page)
    @name = params.fetch(:name)
  end

  def call
    by_name
    sponsors
  end

  private

  def sponsors
    @sponsors ||= Sponsor.includes([:chapters]).reorder('lower(name)').paginate(page: page)
  end

  def by_name
    @sponsors = sponsors.by_name(name) if name.present?
  end
end
