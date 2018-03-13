module ApplicationHelper
  def humanize_date(date, with_time: false)
    human_date = "#{I18n.l(date, format: :day_in_words)}, "
    human_date << "#{ActiveSupport::Inflector.ordinalize(date.day)} "
    human_date << I18n.l(date, format: :month)
    human_date << " at #{I18n.l(date.time, format: :time)}" if with_time
    human_date
  end

  def dot_markdown(text)
    GitHub::Markdown.render_gfm(text).html_safe
  end

  def belongs_to_group?(group)
    current_user.groups.include?(group)
  end

  def has_permission?
    current_user.has_role?(:admin) || current_user.has_role?(:organiser) || Chapter.find_roles(:organiser, current_user).any?
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
end
