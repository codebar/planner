module ApplicationHelper
  def humanize_date(datetime, end_time = nil, with_time: false, with_year: false)
    return I18n.l(datetime, format: :humanised_with_year) if with_year
    return humanize_date_with_time(datetime, end_time) if with_time

    I18n.l(datetime, format: :humanised)
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
    CommonMarker.render_html(text).html_safe
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

  private

  def humanize_date_with_time(datetime, end_time)
    formatted_datetime = I18n.l(datetime, format: :humanised_with_time)
    formatted_datetime << " - #{I18n.l(end_time, format: :time)}" if end_time
    formatted_datetime << " #{I18n.l(datetime, format: :time_zone)}"
    formatted_datetime
  end
end
