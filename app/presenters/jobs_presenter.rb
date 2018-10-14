class JobsPresenter < BasePresenter
  attr_reader :decorated_collection

  def initialize(jobs)
    @decorated_collection = jobs.map { |v| JobPresenter.new(v) }
    super(jobs)
  end

  def each(&block)
    decorated_collection.each(&block)
  end
end
