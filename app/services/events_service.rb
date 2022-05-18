class EventsService 
    RECENT_EVENTS_DISPLAY_LIMIT = 40

    def past_events 
        past_events_grouped_by_date.map.inject({}) do |hash, (key, value)|
            hash[key] = EventPresenter.decorate_collection(value)
            hash
        end
    end

    def events 
        formated_events
    end

    def latest_model_updated
        [
          Workshop.maximum(:updated_at),
          Meeting.maximum(:updated_at),
          Event.maximum(:updated_at),
          Member.maximum(:updated_at)
        ].compact.max
    end

    private 
    
    def formated_events 
        events_grouped_by_date.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.
            decorate_collection(value); hash }
    end
    def events_grouped_by_date
        events = [Workshop.includes(:chapter).upcoming.joins(:chapter).merge(Chapter.active)]
        events << Meeting.upcoming.all
        events << Event.upcoming.includes(:venue, :sponsors).all
        events.compact.flatten.sort_by(&:date_and_time).group_by(&:date)
    end
    def past_events_grouped_by_date
        events = [Workshop.past.includes(:chapter).joins(:chapter).merge(Chapter.active).limit(RECENT_EVENTS_DISPLAY_LIMIT)]
        events << Meeting.past.includes(:venue).limit(RECENT_EVENTS_DISPLAY_LIMIT)
        events << Event.past.includes(:venue, :sponsors).limit(RECENT_EVENTS_DISPLAY_LIMIT)
        events = events.compact.flatten.sort_by(&:date_and_time).reverse.first(RECENT_EVENTS_DISPLAY_LIMIT)
        events.group_by(&:date)
    end
end
