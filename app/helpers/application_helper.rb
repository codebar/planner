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
    CommonMarker.render_html(text, :DEFAULT).html_safe
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

  def link_to_add_fields(name = nil, f = nil, association = nil, options = nil, html_options = nil, &block)
    # If a block is provided there is no name attribute and the arguments are
    # shifted with one position to the left. This re-assigns those values.
    f, association, options, html_options = name, f, association, options if block_given?

    options = {} if options.nil?
    html_options = {} if html_options.nil?

    if options.include? :locals
      locals = options[:locals]
    else
      locals = { }
    end

    if options.include? :partial
      partial = options[:partial]
    else
      partial = association.to_s.singularize + '_fields'
    end

    # Render the form fields from a file with the association name provided
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: 'new_record') do |builder|
      render(partial, locals.merge!( f: builder))
    end

    # The rendered fields are sent with the link within the data-form-prepend attr
    html_options['data-form-prepend'] = raw CGI::escapeHTML( fields )
    html_options['href'] = '#'

    content_tag(:a, name, html_options, &block)
  end

  private

  def humanize_date_with_time(datetime, end_time)
    formatted_datetime = I18n.l(datetime, format: :humanised_with_time)
    formatted_datetime << " - #{I18n.l(end_time, format: :time)}" if end_time
    formatted_datetime << " #{I18n.l(datetime, format: :time_zone)}"
    formatted_datetime
  end
end
