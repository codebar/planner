class Admin::ChaptersController < Admin::ApplicationController
  before_action :set_chapter, only: %i[show edit update]
  after_action :verify_authorized

  def new
    @chapter = Chapter.new
    authorize @chapter
  end

  def create
    @chapter = Chapter.new(chapter_params)
    authorize @chapter

    result = ChapterCreationService.call(chapter_params)
    @chapter = result.chapter

    if result.success
      flash[:notice] = "Chapter #{@chapter.name} has been successfully created"
      redirect_to [:admin, @chapter]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'new'
    end
  end

  def show
    authorize(@chapter)

    @workshops = @chapter.workshops.today_and_upcoming
    @chapter_health = Admin::Dashboard::ChapterHealth.row(chapter: @chapter)
    @past_workshop_dates, @planned_workshop_dates = timeline_dates(@chapter.workshops)
    @past_event_dates, @planned_event_dates = timeline_dates(@chapter.events.single_chapter)
    @sponsors = @chapter.sponsors.uniq
    @groups = @chapter.groups
    @subscribers = @chapter.subscriptions.last(20).reverse
    @how_you_found_us = HowYouFoundUsPresenter.new(@chapter)
  end

  def edit
    authorize @chapter
  end

  def update
    authorize(@chapter)

    if @chapter.update(chapter_params)
      flash[:notice] = "Chapter #{@chapter.name} has been successfully updated"
      redirect_to [:admin, @chapter]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'edit'
    end
  end

  def status
    skip_authorization
    @months = [6, 12].include?(params[:months].to_i) ? params[:months].to_i : 6
    period_start = @months.months.ago.beginning_of_day
    recent_cutoff = (@months - 1).months.ago.beginning_of_day

    chapters = Chapter.all.index_by(&:id)

    ws_data = Chapter.joins(:workshops)
                     .where(workshops: { date_and_time: period_start..3.months.from_now })
                     .pluck(:chapter_id, 'workshops.date_and_time')

    eligible = Member.not_banned.accepted_toc
                     .joins(groups: :chapter)
                     .where(groups: { name: %w[Students Coaches] })
                     .group(:chapter_id, 'groups.name')
                     .count

    ws_by_ch = ws_data.group_by(&:first)

    rows = chapters.map do |ch_id, ch|
      ws_dates = (ws_by_ch[ch_id] || []).map(&:second)
      ws_count = ws_dates.size
      ws_recent = ws_dates.count { |d| d >= recent_cutoff }
      {
        chapter: ch,
        workshops: ws_count,
        recent_workshops: ws_recent,
        eligible_students: eligible.fetch([ch_id, 'Students'], 0),
        eligible_coaches: eligible.fetch([ch_id, 'Coaches'], 0)
      }
    end

    @active = rows.select { |r| r[:workshops].positive? }
                  .sort_by { |r| [-r[:workshops], -(r[:eligible_students] + r[:eligible_coaches])] }

    @dormant = rows.select { |r| r[:workshops].zero? && r[:chapter].active? }
                   .sort_by { |r| -(r[:eligible_students] + r[:eligible_coaches]) }

    @inactive = rows.reject { |r| r[:chapter].active? }
                    .sort_by { |r| -(r[:eligible_students] + r[:eligible_coaches]) }

    @at_risk_ids = @active.select { |r| r[:recent_workshops].zero? }.map { |r| r[:chapter].id }.to_set
  end

  def members
    chapter = Chapter.find(params[:chapter_id])
    authorize chapter
    type = params[:type]

    @emails = member_emails(chapter, type)

    render plain: @emails
  end

  private

  def chapter_params
    params.expect(chapter: %i[name email city time_zone description image])
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def member_emails(chapter, type)
    members =
      case type
      when 'students'
        chapter.students
      when 'coaches'
        chapter.coaches
      else
        chapter.members
      end
    members.distinct.pluck(:email).join("\n")
  end

  def timeline_dates(collection)
    [collection.where(date_and_time: ..Time.zone.now).pluck(:date_and_time),
     collection.where(date_and_time: Time.zone.now..90.days.from_now).pluck(:date_and_time)]
  end
end
