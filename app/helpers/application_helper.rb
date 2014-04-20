module ApplicationHelper

  def humanize_date(date)
    human_date = "#{l(date, format: :day_in_words)}, "
    human_date << "#{ActiveSupport::Inflector.ordinalize(date.day)} "
    human_date << l(date, format: :month)
  end

  def humanize_date_with_time(date)
    human_date = humanize_date(date)
    human_date << " at #{l(date, format: :time)}"
  end

end
