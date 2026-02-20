class HowYouFoundUsPresenter

  def initialize(chapter)
    @chapter = chapter
  end

  def by_percentage
    return how_values.to_h { |how| [how, 0] } unless data_present?

    # use the largest remainder algorithm so that percentages are whole
    # numbers but always add up to 100
    # https://stackoverflow.com/a/13483710/
    entries = how_values.map do |how|
      count = raw_stats.fetch(how, 0)
      exact = (count / total_responses.to_f) * 100
      percentage_value = exact.floor
      remainder = exact - percentage_value
      { how: how, percentage_value: percentage_value, remainder: remainder }
    end

    allocated_so_far = entries.sum { |entry| entry[:percentage_value] }
    left_to_allocate = 100 - allocated_so_far

    entries
      .sort_by { |entry| [-entry[:remainder], entry[:how].to_s] }
      .first(left_to_allocate)
      .each { |entry| entry[:percentage_value] += 1 }

    entries.to_h { |entry| [entry[:how], entry[:percentage_value]] }
  end

  def total_responses
    raw_stats.values.sum(0)
  end

  def data_present?
    total_responses.positive?
  end

  private

  def raw_stats
    @stats ||= @chapter.members.where.not(how_you_found_us: nil).group(:how_you_found_us).count
  end

  def how_values
    Member.how_you_found_us.keys
  end
end
