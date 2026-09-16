module SitemapsHelper
  def sitemap_static_urls
    [root_url, code_of_conduct_url, coaches_url, teaching_guide_url, faq_url,
     attendance_policy_url, student_guide_url, privacy_policy_url, cookie_policy_url,
     breach_code_of_conduct_url, volunteer_url, fundraise_url, donate_url,
     codebar_stories_podcast_url]
  end

  def sitemap_record_sections
    [
      { name: 'chapters', records: Chapter.active, url: ->(chapter) { chapter_url(chapter.slug) } },
      { name: 'workshops', records: Workshop.all, url: ->(workshop) { workshop_url(workshop) } },
      { name: 'events', records: Event.all, url: ->(event) { event_url(event) } },
      { name: 'meetings', records: Meeting.all, url: ->(meeting) { meeting_url(meeting) } }
    ]
  end
end
