module ApplicationHelper
  def humanize_date(date, with_time: false, with_year: false)
    human_date = "#{I18n.l(date, format: :day_in_words)}, "
    human_date << "#{ActiveSupport::Inflector.ordinalize(date.day)} "
    human_date << I18n.l(date, format: :month)
    human_date << " #{I18n.l(date, format: :year)}" if with_year
    human_date << " at #{I18n.l(date.time, format: :time)}" if with_time
    human_date
  end

  def title(title = nil)
    return unless title

    title = title + ' | ' + t(:brand)
    content_for :title, title
  end

  def retrieve_title
    content_for?(:title) ? content_for(:title) : t(:brand)
  end

  def dot_markdown(text)
    GitHub::Markdown.render_gfm(text).html_safe
  end

  def belongs_to_group?(group)
    current_user.groups.include?(group)
  end

  def member_token(member)
    require 'verifier'
    Verifier.new(id: member.id).access_token
  end

  def twitter
    Planner::Application.config.twitter
  end

  def twitter_id
    Planner::Application.config.twitter_id
  end

  def contact_email(workshop: nil)
    @contact_email ||= workshop.present? ? workshop.chapter.email : 'hello@codebar.io'
  end

  def active_link_class(link_path)
    current_page?(link_path) ? 'active' : ''
  end

  def twitter_url_for(username)
    "http://twitter.com/#{username}"
  end

  def page_year?(year)
    (!year_param && year.eql?(Time.zone.now.year)) || year_param == year.to_s
  end
  include ActionView::Helpers::NumberHelper

  def number_to_currency(number, options = {})
    options[:locale] = 'en'
    super(number, options)
  end
end
