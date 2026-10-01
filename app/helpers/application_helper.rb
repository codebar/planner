module ApplicationHelper
  include DigestHelper

  # Rendered head asset tags are request-independent: the digest path depends
  # only on the asset manifest, which is frozen for the process lifetime when
  # the pipeline does not compile on demand (production sets
  # config.assets.compile = false). Memoizing the tag HTML skips the
  # per-request digest lookup and tag construction. Development compiles at
  # runtime and digests change without a restart, so it renders uncached.
  # Mutable by design: cross-request memo keyed by helper + arguments.
  HEAD_ASSET_TAG_CACHE = {} # rubocop:disable Style/MutableConstant

  def stylesheet_link_tag(*args)
    head_asset_tag([:stylesheet, args]) { super }
  end

  def javascript_include_tag(*args)
    head_asset_tag([:javascript, args]) { super }
  end

  def favicon_link_tag(*args)
    head_asset_tag([:favicon, args]) { super }
  end

  def humanize_date(datetime, end_time = nil, with_time: false, with_year: false)
    return I18n.l(datetime, format: :humanised_with_year) if with_year
    return humanize_date_with_time(datetime, end_time) if with_time

    I18n.l(datetime, format: :humanised)
  end

  def title(title = nil)
    return unless title

    title = "#{title} | #{t(:brand)}"
    content_for :title, title
  end

  def retrieve_title
    content_for?(:title) ? content_for(:title) : t(:brand)
  end

  # Absolute URL for a social preview image, falling back to the codebar social image
  def social_image_url(url = nil)
    image = url.presence || image_url('codebar-social.jpg')
    # URI.join on an absolute path always yields base_url + path, and base_url
    # carries scheme/host/port only, so plain interpolation is equivalent.
    image.start_with?('/') ? "#{request.base_url}#{image}" : image
  end

  def head_asset_tag(key)
    return yield if Rails.env.development?

    HEAD_ASSET_TAG_CACHE[key] ||= yield
  end

  def dot_markdown(text)
    # Commonmarker sanitises raw HTML; `.html_safe` prevents Rails double-escaping the result
    # rubocop:disable Rails/OutputSafety
    Commonmarker.to_html(text).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def belongs_to_group?(group)
    current_user.groups.include?(group)
  end

  def member_token(member)
    require 'verifier'
    Verifier.new(id: member.id).access_token
  end

  def contact_email(workshop: nil)
    @contact_email ||= workshop.present? ? workshop.chapter.email : 'hello@codebar.io'
  end

  def active_link_class(link_path)
    current_page?(link_path) ? 'active' : ''
  end

  def page_year?(year)
    (!year_param && year.eql?(Time.zone.now.year)) || year_param == year.to_s
  end
  include ActionView::Helpers::NumberHelper

  def number_to_currency(number, options = {})
    options[:locale] = 'en'
    super(number, options)
  end

  def sponsorship_level_title(level)
    return t('sponsors.standard_title') if level === 'standard'
    return t('sponsors.community_partner_title') if level === 'community'

    "#{level.humanize} sponsors"
  end

  # Admin-page subject of a member activity: the entity the action was about.
  # Returns nil when the subject is the member themselves (e.g. logins, bans).
  def activity_subject(activity)
    case (trackable = activity.trackable)
    when WorkshopInvitation then trackable.workshop
    when Invitation then trackable.event
    when MeetingInvitation then trackable.meeting
    when Member then nil
    else trackable
    end
  end

  def activity_subject_label(subject)
    return "#{subject.chapter.name} #{subject.name}" if subject.is_a?(Group)
    return subject.full_name if subject.respond_to?(:full_name)

    subject.try(:name) || subject.to_s
  end

  private

  def humanize_date_with_time(datetime, end_time)
    formatted_datetime = I18n.l(datetime, format: :humanised_with_time)
    formatted_datetime << " - #{I18n.l(end_time, format: :time)}" if end_time
    formatted_datetime << " #{I18n.l(datetime, format: :time_zone)}"
    formatted_datetime
  end
end
