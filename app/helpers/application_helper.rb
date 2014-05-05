module ApplicationHelper

  def humanize_date(date)
    human_date = "#{I18n.l(date, format: :day_in_words)}, "
    human_date << "#{ActiveSupport::Inflector.ordinalize(date.day)} "
    human_date << I18n.l(date, format: :month)
  end

  def humanize_date_with_time(date)
    human_date = humanize_date(date)
    human_date << " at #{I18n.l(date, format: :time)}"
  end

  def dot_markdown(text)
    GitHub::Markdown.render_gfm(text).html_safe
  end

end
