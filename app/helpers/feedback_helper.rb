module FeedbackHelper
  def recent_workshop_details
    recent_workshops = Workshop.recent.includes(:chapter)

    recent_workshops.each_with_object({}) do |workshop, recent_workshops_details|
      recent_workshops_details[workshop.id] = "#{workshop.chapter.name} - #{workshop.date_and_time.strftime('%A, %b %d')}"
    end
  end
end
