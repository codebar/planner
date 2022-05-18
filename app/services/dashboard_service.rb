class DashboardService 

    DEFAULT_UPCOMING_EVENTS = 5

    def initialize(user = nil)
      @user = user
    end

    def ordered_events  
        upcoming_events_for_user.map.inject({}) do |hash, (key, value)|
            hash[key] = EventPresenter.decorate_collection(value)
            hash
        end
    end

    def upcoming_workshops 
        upcoming_events.map.inject({}) do |hash, (key, value)|
        hash[key] = EventPresenter.decorate_collection(value)
            hash
        end
    end

    def coaches_count
        top_coach_query.length
    end

    def coaches(page, year_param)
        Member.where(id: top_coach_query
            .year(year_param))
            .includes(:skills)
            .paginate(page: page)
    end

    
    private     
    
    def upcoming_events_for_user
        all_events(chapter_workshops(@user) + accepted_workshops(@user))
          .sort_by(&:date_and_time)
          .group_by(&:date)
      end 
      def upcoming_events
          workshops = Workshop.upcoming.includes(:chapter, :sponsors)
          all_events(workshops).sort_by(&:date_and_time).group_by(&:date)
      end

    def accepted_workshops
        @user.workshop_invitations
                    .accepted
                    .joins(:workshop)
                    .merge(Workshop.upcoming)
                    .includes(workshop: %i[chapter sponsors])
                    .map(&:workshop)
    end
    def chapter_workshops
        Workshop.upcoming
                .where(chapter: @user.chapters)
                .includes(:chapter, :sponsors)
                .to_a
    end
    def all_events(workshops)
        meeting = Meeting.includes(:venue).next
        events = Event.includes(:venue, :sponsors).upcoming.take(DEFAULT_UPCOMING_EVENTS)
    
        [*workshops, *events, meeting].uniq.compact
    end

    def top_coach_query
        WorkshopInvitation.to_coaches
                          .attended
                          .group(:member_id)
                          .order(Arel.sql('COUNT(member_id) DESC'))
                          .select(:member_id)
      end
end
