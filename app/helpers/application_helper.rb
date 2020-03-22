module ApplicationHelper
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

  def contact_email
    @contact_email ||= @workshop.present? ? @workshop.chapter.email : 'hello@codebar.io'
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
